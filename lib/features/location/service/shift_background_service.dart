// ignore_for_file: unreachable_from_main

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:omkar_sale/commons/repositories/setting_local_repositories.dart';
import 'package:omkar_sale/core/api/api_end_points.dart';
import 'package:omkar_sale/features/location/model/location_point.dart';
import 'package:omkar_sale/features/location/repository/location_repository.dart';
import 'package:path_provider/path_provider.dart';

// ---------------------------------------------------------------------------
// BACKGROUND SERVICE ENTRY POINT
// Must be a top-level function annotated with @pragma('vm:entry-point').
// Runs in a separate Dart isolate — keeps location tracking alive
// even when the main Flutter engine is killed by the OS.
// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
Future<void> onShiftServiceStart(ServiceInstance service) async {
  final tracker = _BackgroundLocationTracker(service);
  await tracker.initialize();
}

class _BackgroundLocationTracker {
  _BackgroundLocationTracker(this.service);

  final ServiceInstance service;

  String? token;
  int interval = 15;
  bool isTrackingInitialized = false;

  StreamSubscription<Position>? positionSubscription;
  Timer? heartbeatTimer;
  Timer? recoveryTimer;
  Timer? watchdogTimer;
  Timer? staleStreamTimer;

  bool isSyncing = false;

  double? lastSavedLat;
  double? lastSavedLon;
  DateTime? lastSavedTimestamp;
  DateTime? lastSavedWallTime;
  DateTime? lastSyncTime;
  DateTime? lastStreamEventTime;

  bool isActive = false;

  // --- HIVE DIRECT OPERATIONS ---
  // --- HIVE DIRECT OPERATIONS ---
  Future<Box> openLocationBox() async {
    if (!Hive.isAdapterRegistered(LocationPointAdapter().typeId)) {
      Hive.registerAdapter(LocationPointAdapter());
    }
    if (Hive.isBoxOpen(LocationRepository.kHiveBoxName)) {
      return Hive.box(LocationRepository.kHiveBoxName);
    }
    return Hive.openBox(LocationRepository.kHiveBoxName);
  }

  Future<void> saveLocationPoint(LocationPoint point) async {
    try {
      final box = await openLocationBox();
      final todayData = Map<dynamic, dynamic>.from(
        box.get(point.date) as Map? ?? {},
      );

      final locationList = List<dynamic>.from(
        todayData['location'] as Iterable? ?? [],
      );

      final newLocEntry = {
        'date': point.date,
        'time': point.timestamp.millisecondsSinceEpoch,
        'lat': point.latitude,
        'long': point.longitude,
      };

      locationList.add(newLocEntry);
      todayData['location'] = locationList;

      await box.put(point.date, todayData);

      // Update liveness key so workmanager watchdog (separate isolate)
      // correctly detects bg isolate is alive and skips needless restart.
      try {
        final prefs = Hive.isBoxOpen('app_preferences')
            ? Hive.box<dynamic>('app_preferences')
            : await Hive.openBox<dynamic>('app_preferences');
        await prefs.put(
          'lastFixEpochMs',
          DateTime.now().millisecondsSinceEpoch,
        );
      } on Exception catch (_) {}
      print('✅ BG SAVED: ${point.latitude}, ${point.longitude}');

      // Retrieve the data from Hive right after saving to verify/inspect it
      final retrievedData = box.get(point.date);
      if (retrievedData is Map) {
        final formattedData = Map<String, dynamic>.from(retrievedData);
        if (formattedData['location'] is List) {
          final locs = List<dynamic>.from(formattedData['location'] as Iterable).map((loc) {
            if (loc is Map) {
              final newLoc = Map<String, dynamic>.from(loc);
              final timeVal = newLoc['time'];
              if (timeVal is int) {
                final dt = DateTime.fromMillisecondsSinceEpoch(timeVal);
                newLoc['time'] = DateFormat('dd-MM-yyyy HH:mm:ss').format(dt);
              }
              return newLoc;
            }
            return loc;
          }).toList();
          formattedData['location'] = locs;
        }
        print('📦 RETRIEVED FROM HIVE AFTER SAVE:');
        const JsonEncoder.withIndent('  ')
            .convert(formattedData)
            .split('\n')
            .forEach(print);
      } else {
        print('📦 RETRIEVED FROM HIVE AFTER SAVE: $retrievedData');
      }
    } on Exception catch (e) {
      print('❌ BG SAVE ERROR: $e');
    }
  }

  Future<bool> syncLocationsDirect(
    String authToken,
    Box box, {
    int chunkSize = 500,
  }) async {
    final dateKeys = box.keys.toList();
    if (dateKeys.isEmpty) {
      print('✅ BG REPO: Nothing to sync.');
      return true;
    }

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    try {
      for (final dateKey in dateKeys) {
        final locBoxData = box.get(dateKey);
        if (locBoxData is! Map || locBoxData['location'] == null) continue;

        final allLocations = List<dynamic>.from(
          locBoxData['location'] as Iterable? ?? [],
        );
        if (allLocations.isEmpty) continue;

        print(
          '🚀 BG REPO: Syncing ${allLocations.length} points for $dateKey in chunks of $chunkSize...',
        );

        final failedCoordinates = <dynamic>[];

        for (var i = 0; i < allLocations.length; i += chunkSize) {
          final end = (i + chunkSize < allLocations.length)
              ? i + chunkSize
              : allLocations.length;
          final chunk = allLocations.sublist(i, end);

          final body = <String, dynamic>{};
          var apiIndex = 0;
          for (final point in chunk) {
            if (point is Map) {
              final lat = point['lat'];
              final lon = point['long'];
              final timeVal = point['time'];

              if (lat != null && lon != null) {
                final doubleLat = lat is num
                    ? lat.toDouble()
                    : double.tryParse(lat.toString()) ?? 0.0;
                final doubleLon = lon is num
                    ? lon.toDouble()
                    : double.tryParse(lon.toString()) ?? 0.0;

                final dateTime = timeVal is int
                    ? DateTime.fromMillisecondsSinceEpoch(timeVal)
                    : DateTime.now();
                final formattedDateTime = DateFormat(
                  'yyyy-MM-dd HH:mm:ss',
                ).format(dateTime);

                body['location[$apiIndex][latitude]'] = doubleLat;
                body['location[$apiIndex][longitude]'] = doubleLon;
                body['location[$apiIndex][date_time]'] = formattedDateTime;
                apiIndex++;
              }
            }
          }

          if (body.isEmpty) continue;

          try {
            final response = await dio.post<Map<String, dynamic>>(
              updateUserLocationUrl,
              data: FormData.fromMap(body),
              options: Options(
                headers: {
                  'Authorization': 'Bearer $authToken',
                },
              ),
            );

            if (response.data != null && response.data!['error'] as bool) {
              throw Exception(response.data!['message'] as String);
            }
          } catch (e) {
            failedCoordinates.addAll(allLocations.sublist(i));
            print('❌ BG SYNC CHUNK ERROR: $e');
            break;
          }
        }

        if (failedCoordinates.isEmpty) {
          await box.delete(dateKey);
        } else {
          await box.put(dateKey, {'location': failedCoordinates});
        }
      }
      return true;
    } on Exception catch (e) {
      print('❌ BG SYNC ERROR: $e');
      return false;
    }
  }

  Future<void> syncToServer() async {
    if (isSyncing || token == null) return;
    isSyncing = true;
    try {
      final box = await openLocationBox();
      final success = await syncLocationsDirect(token!, box);
      if (success) {
        lastSyncTime = DateTime.now();
      }
    } on Exception catch (e) {
      print('❌ BG syncToServer error: $e');
    } finally {
      isSyncing = false;
    }
  }

  // --- STREAM MANAGEMENT ---
  Future<void> startStream() async {
    await positionSubscription?.cancel();
    positionSubscription = null;

    late LocationSettings locationSettings;

    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        intervalDuration: const Duration(seconds: 5),
        distanceFilter: 5,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: '',
          notificationTitle: 'Location Service',
          notificationChannelName: 'Location Tracking',
          enableWakeLock: true,
          notificationIcon: AndroidResource(name: 'ic_transparent'),
        ),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      );
    }

    positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen(
          (position) async {
            // Mark stream liveness BEFORE gates so stationary/filtered fixes
            // still prove stream alive to stale-stream watchdog.
            lastStreamEventTime = DateTime.now();

            print('BG _processLocation: ${position.toJson()}');

            // GATE 1: ACCURACY (<=50m)
            if (position.accuracy > 50) return;

            // GATE 2: STALE DATA (<=60s)
            final ageSeconds = DateTime.now()
                .difference(position.timestamp)
                .inSeconds
                .abs();
            if (ageSeconds > 60) return;

            // GATE 2.5: INTERNAL SESSION TIMEOUT (>= 5 min silence)
            if (lastSavedWallTime != null) {
              final silenceSeconds = DateTime.now()
                  .difference(lastSavedWallTime!)
                  .inSeconds;
              if (silenceSeconds >= 300) {
                lastSavedLat = null;
                lastSavedLon = null;
                lastSavedTimestamp = null;
                lastSavedWallTime = null;
              }
            }

            // GATE 3: SPEED (<=70 m/s)
            if (position.speed > 70) return;

            // GATE 4: JITTER (<3m, speed<5m/s)
            if (lastSavedLat != null &&
                lastSavedLon != null &&
                lastSavedTimestamp != null) {
              final timeDiffSeconds = position.timestamp
                  .difference(lastSavedTimestamp!)
                  .inSeconds
                  .abs();
              if (timeDiffSeconds < 1) return;

              if (position.speed < 5) {
                final distance = Geolocator.distanceBetween(
                  lastSavedLat!,
                  lastSavedLon!,
                  position.latitude,
                  position.longitude,
                );
                if (distance < 3) return;
              }
            }

            // ACCEPTED — SAVE
            lastSavedLat = position.latitude;
            lastSavedLon = position.longitude;
            lastSavedTimestamp = position.timestamp;
            lastSavedWallTime = DateTime.now();

            final todayStr = DateFormat(
              'dd-MM-yyyy',
            ).format(position.timestamp);
            final point = LocationPoint(
              latitude: position.latitude,
              longitude: position.longitude,
              speed: position.speed,
              timestamp: position.timestamp,
              date: todayStr,
            );

            await saveLocationPoint(point);

            // Check sync triggers immediately
            final box = await openLocationBox();
            final todayData = box.get(todayStr);
            var count = 0;
            if (todayData is Map && todayData['location'] is List) {
              count = (todayData['location'] as List).length;
            }

            if (count >= 500) {
              await syncToServer();
            } else {
              final elapsed = DateTime.now().difference(
                lastSyncTime ??
                    DateTime.now().subtract(const Duration(hours: 1)),
              );
              if (elapsed.inSeconds >= (interval * 60)) {
                await syncToServer();
              }
            }
          },
          onError: (Object? error) {
            print('❌ BG TRACKER: Stream error: $error');

            // Start recovery poller if it's not already running
            recoveryTimer ??= Timer.periodic(const Duration(seconds: 15), (
              _,
            ) async {
              if (!isActive) {
                recoveryTimer?.cancel();
                recoveryTimer = null;
                return;
              }

              final permission = await Geolocator.checkPermission();
              final hasPermission =
                  permission == LocationPermission.always ||
                  permission == LocationPermission.whileInUse;
              if (!hasPermission) return;

              final serviceEnabled =
                  await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) return;

              recoveryTimer?.cancel();
              recoveryTimer = null;

              lastSavedLat = null;
              lastSavedLon = null;
              lastSavedTimestamp = null;
              lastSavedWallTime = null;

              await startStream();
            });
          },
        );
  }

  Future<void> checkSyncDue() async {
    if (!isActive || isSyncing || token == null) return;

    final elapsed = DateTime.now().difference(
      lastSyncTime ?? DateTime.now().subtract(const Duration(hours: 1)),
    );

    if (elapsed.inSeconds < (interval * 60)) return;

    final box = await openLocationBox();
    final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final todayData = box.get(todayStr);
    var count = 0;
    if (todayData is Map && todayData['location'] is List) {
      count = (todayData['location'] as List).length;
    }

    if (count > 0) {
      await syncToServer();
      return;
    }

    // Stationary recovery - get a fresh GPS fix
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      if (position.accuracy <= 50) {
        // Run process gates manually on heartbeat fix
        if (position.speed <= 70) {
          lastSavedLat = position.latitude;
          lastSavedLon = position.longitude;
          lastSavedTimestamp = position.timestamp;
          lastSavedWallTime = DateTime.now();

          final point = LocationPoint(
            latitude: position.latitude,
            longitude: position.longitude,
            speed: position.speed,
            timestamp: position.timestamp,
            date: DateFormat('dd-MM-yyyy').format(position.timestamp),
          );

          await saveLocationPoint(point);
          await syncToServer();
        }
      }
    } on Exception catch (_) {}
  }

  Future<void> startTracking() async {
    if (isTrackingInitialized) return;
    isTrackingInitialized = true;
    isActive = true;
    lastSavedLat = null;
    lastSavedLon = null;
    lastSavedTimestamp = null;
    lastSavedWallTime = null;
    lastStreamEventTime = DateTime.now();
    lastSyncTime = DateTime.now();

    await startStream();

    heartbeatTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => checkSyncDue(),
    );

    staleStreamTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => watchStaleStream(),
    );
  }

  Future<void> watchStaleStream() async {
    if (!isActive) return;
    final last = lastStreamEventTime;
    final now = DateTime.now();

    if (last != null && now.difference(last).inSeconds < 120) {
      // Stream alive — write heartbeat for cross-isolate watchdog.
      try {
        final prefs = Hive.isBoxOpen('app_preferences')
            ? Hive.box<dynamic>('app_preferences')
            : await Hive.openBox<dynamic>('app_preferences');
        await prefs.put('lastStreamEpochMs', now.millisecondsSinceEpoch);
      } on Exception catch (_) {}
      return;
    }

    final ageSec = last == null ? -1 : now.difference(last).inSeconds;
    print('⚠️ BG: stream stale (${ageSec}s since last emit) — restarting');

    lastSavedLat = null;
    lastSavedLon = null;
    lastSavedTimestamp = null;
    lastSavedWallTime = null;
    lastStreamEventTime = now;

    try {
      await startStream();
      print('🔄 BG: stream restarted by stale watchdog');
    } on Exception catch (e) {
      print('❌ BG: stale-stream restart failed: $e');
    }
  }

  // --- CLEANUP ---
  Future<void> stopTracking() async {
    isActive = false;
    watchdogTimer?.cancel();
    heartbeatTimer?.cancel();
    recoveryTimer?.cancel();
    staleStreamTimer?.cancel();
    await positionSubscription?.cancel();

    // Final sync attempt (Temporarily commented for testing)
    if (token != null) {
      try {
        final box = await openLocationBox();
        await syncLocationsDirect(token!, box);
        await box.close();
      } on Exception catch (_) {}
    }

    // Set isActive = false in shift_config
    try {
      final configBox = await Hive.openBox<dynamic>('shift_config');
      await configBox.put('isActive', false);
      await configBox.close();
    } on Exception catch (_) {}

    service.stopSelf();
  }

  Future<void> initialize() async {
    // 1. Initialize PathProvider and Hive in this isolate
    try {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    } on Exception catch (e) {
      print('❌ BG TRACKER: Failed to initialize Hive path: $e');
    }

    final completer = Completer<void>();

    service.on('init').listen((event) async {
      if (event == null) return;
      token = event['token'] as String?;
      interval = event['interval'] as int? ?? 15;

      // Save to Hive config for WatchdogReceiver survival
      if (token != null) {
        try {
          final configBox = await Hive.openBox<dynamic>('shift_config');
          await configBox.put('token', token);
          await configBox.put('interval', interval);
          await configBox.put('isActive', true);
          await configBox.close();
        } on Exception catch (_) {}
      }

      if (!completer.isCompleted) completer.complete();

      if (isTrackingInitialized) {
        // Re-configure heartbeat timer
        heartbeatTimer?.cancel();
        heartbeatTimer = Timer.periodic(
          const Duration(seconds: 60),
          (_) => checkSyncDue(),
        );
      } else {
        startTracking();
      }
    });

    service.on('stopService').listen((_) async {
      await stopTracking();
    });

    service.on('restartStream').listen((_) async {
      print('🔄 BG: restartStream event received');
      if (!isActive) return;
      lastSavedLat = null;
      lastSavedLon = null;
      lastSavedTimestamp = null;
      lastSavedWallTime = null;
      lastStreamEventTime = DateTime.now();
      try {
        await startStream();
        print('🔄 BG: stream restarted by external event');
      } on Exception catch (e) {
        print('❌ BG: restartStream failed: $e');
      }
    });

    final currentService = service;
    if (currentService is AndroidServiceInstance) {
      watchdogTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        if (await currentService.isForegroundService()) {
          currentService.setForegroundNotificationInfo(
            title: 'Omkar - Shift Active',
            content: 'Tracking your shift location',
          );
        }
      });
    }

    // Wait 5s for the main app to send the init config
    Future.delayed(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    await completer.future;

    // Fallback: If init was not received (WatchdogReceiver restart), load config from Hive
    if (token == null) {
      try {
        final configBox = await Hive.openBox<dynamic>('shift_config');
        final savedActive = configBox.get('isActive') as bool? ?? false;
        final savedToken = configBox.get('token') as String?;
        final savedInterval = configBox.get('interval') as int? ?? 15;
        await configBox.close();

        if (savedActive && savedToken != null && savedToken.isNotEmpty) {
          token = savedToken;
          interval = savedInterval;
          await startTracking();
        } else {
          await stopTracking();
        }
      } on Exception catch (_) {
        await stopTracking();
      }
    }
  }
}

// ---------------------------------------------------------------------------
// PUBLIC API
// ---------------------------------------------------------------------------

/// Call once at app startup from main() — BEFORE runApp.
Future<void> configureShiftService() async {
  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onShiftServiceStart,
      autoStart: false,
      isForegroundMode: true,
      initialNotificationTitle: 'Omkar - Shift Active',
      initialNotificationContent: 'Tracking your shift location',
      foregroundServiceNotificationId: 1001,
      foregroundServiceTypes: [AndroidForegroundType.dataSync],
    ),
    iosConfiguration: IosConfiguration(autoStart: false),
  );
}

/// Start the foreground notification service on clock-in.
Future<void> startShiftService(String token, int interval) async {
  // Save shift config for watchdog restart survival
  await SettingLocalRepository.instance.saveShiftConfig(
    token: token,
    interval: interval,
    isActive: true,
  );

  final service = FlutterBackgroundService();
  if (await service.isRunning()) {
    service.invoke('init', {'token': token, 'interval': interval});
    return;
  }

  await service.startService();
  // Wait a small moment for service isolate initialization, then invoke init
  await Future<void>.delayed(const Duration(milliseconds: 500));
  service.invoke('init', {'token': token, 'interval': interval});
}

/// Stop the foreground notification service on clock-out.
void stopShiftService() {
  FlutterBackgroundService().invoke('stopService');
}
