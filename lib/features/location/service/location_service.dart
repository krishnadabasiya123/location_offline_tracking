import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/location/service/shift_background_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// =============================================================================
// LOCATION TRACKER (Singleton Wrapper)
// =============================================================================

class LocationTracker {
  LocationTracker._();
  static final LocationTracker instance = LocationTracker._();

  bool _isRunning = false;

  // iOS background properties
  StreamSubscription<Position>? _iosPositionSub;
  Timer? _iosSyncTimer;
  final LocationRepository _repo = LocationRepository();

  bool get isRunning => _isRunning;

  // ---------------------------------------------------------------------------
  // START
  // ---------------------------------------------------------------------------

  Future<void> start() async {
    if (_isRunning) {
      print('📍 TRACKER: Already running.');
      return;
    }

    // Enable CPU Wakelock to keep CPU awake when app is minimized / screen off
    try {
      await WakelockPlus.enable();
      print('⚡ TRACKER: Wakelock enabled');
    } on Exception catch (e) {
      print('❌ TRACKER: Failed to enable Wakelock: $e');
    }

    _isRunning = true;

    if (Platform.isAndroid) {
      try {
        final token = AuthLocalRepository.instance.getJwtToken();
        final interval = SettingLocalRepository.instance
            .getLocationUpdateInterval();
        await startShiftService(token, interval);
      } on Exception catch (e) {
        print('⚠️ TRACKER: startShiftService failed: $e');
      }
    } else if (Platform.isIOS) {
      try {
        final locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.fitness,
          distanceFilter: 10,
          showBackgroundLocationIndicator: true,
        );

        await _iosPositionSub?.cancel();
        _iosPositionSub =
            Geolocator.getPositionStream(
              locationSettings: locationSettings,
            ).listen((position) async {
              print(
                '📍 IOS BACKGROUND FIX: ${position.latitude}, ${position.longitude}',
              );
              final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
              final point = LocationPoint(
                latitude: position.latitude,
                longitude: position.longitude,
                timestamp: DateTime.now(),
                date: todayStr,
              );
              await _repo.saveLocal(point);
              await SettingLocalRepository.instance.setLastFixEpochMs(
                DateTime.now().millisecondsSinceEpoch,
              );
            });

        _iosSyncTimer?.cancel();
        _iosSyncTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
          final pending = _repo.getCount();
          if (pending > 0) {
            print('📤 IOS: flushing $pending point(s) to server...');
            try {
              await _repo.syncToServer();
            } catch (e) {
              print('⚠️ IOS: periodic sync failed: $e');
            }
          }
        });
      } on Exception catch (e) {
        print('❌ TRACKER: Failed to start iOS geolocator stream: $e');
      }
    }

    print('✅ TRACKER: Thin wrapper started on main isolate.');
  }

  // ---------------------------------------------------------------------------
  // STOP
  // ---------------------------------------------------------------------------

  Future<void> stop() async {
    if (!_isRunning) return;
    _isRunning = false;

    // Release CPU Wakelock when tracking is stopped
    try {
      await WakelockPlus.disable();
      print('⚡ TRACKER: Wakelock disabled');
    } on Exception catch (e) {
      print('❌ TRACKER: Failed to disable Wakelock: $e');
    }

    if (Platform.isAndroid) {
      try {
        stopShiftService();
        // Poll until background service fully stops (final sync + stopSelf).
        // Max 3 s — avoids blocking clockOut indefinitely if service hangs.
        const maxWait = Duration(seconds: 3);
        final deadline = DateTime.now().add(maxWait);
        while (await FlutterBackgroundService().isRunning() &&
            DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
      } on Exception catch (e) {
        print('⚠️ TRACKER: stopShiftService failed: $e');
      }
    } else if (Platform.isIOS) {
      try {
        await _iosPositionSub?.cancel();
        _iosPositionSub = null;

        _iosSyncTimer?.cancel();
        _iosSyncTimer = null;

        print('🛑 IOS TRACKER: Background geolocator stream stopped.');
      } on Exception catch (e) {
        print('⚠️ TRACKER: Failed to stop iOS geolocator stream: $e');
      }
    }

    print('🛑 TRACKER: Thin wrapper stopped.');
  }

  // ---------------------------------------------------------------------------
  // RESUME — call from app lifecycle resumed event
  // ---------------------------------------------------------------------------

  void onResume() {
    if (!_isRunning) return;

    if (Platform.isAndroid) {
      try {
        final token = AuthLocalRepository.instance.getJwtToken();
        final interval = SettingLocalRepository.instance
            .getLocationUpdateInterval();
        FlutterBackgroundService().invoke('init', {
          'token': token,
          'interval': interval,
        });
      } on Exception catch (e) {
        print('⚠️ TRACKER: onResume configuration refresh failed: $e');
      }
    }

    print('🔄 TRACKER: Thin wrapper resumed — background config refreshed.');
  }

  // ---------------------------------------------------------------------------
  // UPDATE INTERVAL
  // ---------------------------------------------------------------------------

  void updateInterval(int newIntervalMinutes) {
    if (_isRunning && Platform.isAndroid) {
      try {
        final token = AuthLocalRepository.instance.getJwtToken();
        FlutterBackgroundService().invoke('init', {
          'token': token,
          'interval': newIntervalMinutes,
        });
      } on Exception catch (e) {
        print('⚠️ TRACKER: updateInterval configuration refresh failed: $e');
      }
    }
  }

  bool _sessionCheckDone = false;

  /// Returns true only on the first query of the app session if the tracker is stopped.
  bool shouldPromptRestore() {
    if (_sessionCheckDone) return false;
    _sessionCheckDone = true;
    return !_isRunning;
  }
}
