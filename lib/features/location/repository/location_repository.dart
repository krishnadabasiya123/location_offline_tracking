import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/utils/connectivity.dart';
import 'package:path_provider/path_provider.dart';

class LocationRepository {
  static const String kHiveBoxName = 'locationDataBox';

  static bool _isSyncing = false;

  Box get _box => Hive.box(kHiveBoxName);

  /// Save location point locally in date-partitioned structure
  Future<void> saveLocal(LocationPoint point) async {
    if (!Hive.isBoxOpen(kHiveBoxName)) {
      await Hive.openBox(kHiveBoxName);
    }
    final box = _box;
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
  }

  /// Get count of local unsynced points for today
  int getCount() {
    if (!Hive.isBoxOpen(kHiveBoxName)) return 0;
    final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final box = _box;
    final todayData = box.get(todayStr);
    if (todayData is Map && todayData['location'] is List) {
      return (todayData['location'] as List).length;
    }
    return 0;
  }

  /// Sync locations to server date-wise and within time limits (Compatibility Wrapper)
  Future<Map<String, dynamic>> syncLocationsToServer({
    required String date,
    int? upToTimestamp,
    int? fromTimestamp,
    int chunkSize = 500,
  }) async {
    final result = await syncLocationsForShift(
      dates: [date],
      upToTimestamp: upToTimestamp,
      fromTimestamp: fromTimestamp,
      chunkSize: chunkSize,
    );
    return {
      'success': result['success'] ?? false,
      'failed': result['failed'] ?? [],
    };
  }

  /// Sync locations across multiple dates spanned by the shift
  Future<Map<String, dynamic>> syncLocationsForShift({
    required List<String> dates,
    int? upToTimestamp,
    int? fromTimestamp,
    int chunkSize = 500,
  }) async {
    if (_isSyncing) {
      print('⏳ REPO: Sync already in progress, skipping...');
      return {'success': true, 'failed': []};
    }
    _isSyncing = true;
    try {
      if (Hive.isBoxOpen(kHiveBoxName)) {
        try {
          await Hive.box(kHiveBoxName).close();
        } catch (e) {
          print('⚠️ REPO: Ignored error closing box: $e');
        }
      }
      final locBox = await Hive.openBox(kHiveBoxName);
      // Collect and map all coordinates with their source date
      final List<Map<String, dynamic>> allCoordinates = [];
      for (final date in dates) {
        final locBoxData = locBox.get(date);
        if (locBoxData != null &&
            locBoxData is Map &&
            locBoxData['location'] != null) {
          final locs = List<dynamic>.from(
            locBoxData['location'] as Iterable? ?? [],
          );
          for (final loc in locs) {
            if (loc is Map) {
              allCoordinates.add({
                'date': date,
                'entry': Map<String, dynamic>.from(loc),
              });
            }
          }
        }
      }
      // Filter locations to sync vs locations to keep
      final List<Map<String, dynamic>> coordinatesToSync = [];
      final List<Map<String, dynamic>> coordinatesToKeep = [];
      for (final item in allCoordinates) {
        final loc = item['entry'];
        final int? locTime = loc['time'] as int?;
        if (locTime == null) {
          coordinatesToSync.add(item);
          continue;
        }
        final isAfterClockIn =
            fromTimestamp == null || locTime >= fromTimestamp;
        final isBeforeClockOut =
            upToTimestamp == null || locTime <= upToTimestamp;
        if (isAfterClockIn && isBeforeClockOut) {
          coordinatesToSync.add(item);
        } else {
          coordinatesToKeep.add(item);
        }
      }
      var isSyncSuccess = true;
      final List<Map<String, dynamic>> failedCoordinates = [];
      if (coordinatesToSync.isNotEmpty) {
        print(
          '🚀 REPO: Uploading ${coordinatesToSync.length} combined coordinates in chunks...',
        );
        for (var i = 0; i < coordinatesToSync.length; i += chunkSize) {
          final end = (i + chunkSize < coordinatesToSync.length)
              ? i + chunkSize
              : coordinatesToSync.length;
          final chunk = coordinatesToSync.sublist(i, end);
          final rawChunkEntries = chunk.map((c) => c['entry']).toList();
          // Print the chunk details to be synced (formatted time)
          final formattedChunk = rawChunkEntries.map((loc) {
            final newLoc = Map<String, dynamic>.from(loc as Map);
            final timeVal = newLoc['time'];
            if (timeVal is int) {
              final dt = DateTime.fromMillisecondsSinceEpoch(timeVal);
              newLoc['time'] = DateFormat('dd-MM-yyyy HH:mm:ss').format(dt);
            }
            return newLoc;
          }).toList();
          print(
            '📤 REPO: Syncing combined chunk [${i + 1} to $end] of ${coordinatesToSync.length}. Data: $formattedChunk',
          );
          // Check connection
          final hasInternet = await InternetConnectivity.checkInternet();
          if (!isSyncSuccess || !hasInternet) {
            isSyncSuccess = false;
            failedCoordinates.addAll(coordinatesToSync.sublist(i));
            print('❌ REPO: Internet lost during sync.');
            break;
          }
          final success = await _uploadLocationChunkApi(rawChunkEntries);
          if (!success) {
            isSyncSuccess = false;
            failedCoordinates.addAll(coordinatesToSync.sublist(i));
            print('❌ REPO: Chunk upload failed.');
            break;
          }
        }
        // Re-open Hive box just in case
        final activeLocBox = Hive.isBoxOpen(kHiveBoxName)
            ? Hive.box(kHiveBoxName)
            : await Hive.openBox(kHiveBoxName);
        // Group the remaining/failed coordinates by date so we can save them back
        final Map<String, List<dynamic>> updatedLocationsByDate = {};
        for (final date in dates) {
          updatedLocationsByDate[date] = [];
        }
        // Add kept coordinates back
        for (final item in coordinatesToKeep) {
          final d = item['date'] as String;
          updatedLocationsByDate[d]?.add(item['entry']);
        }
        // Add failed coordinates back (to retry later)
        for (final item in failedCoordinates) {
          final d = item['date'] as String;
          updatedLocationsByDate[d]?.add(item['entry']);
        }
        // Save back to Hive
        for (final date in dates) {
          final list = updatedLocationsByDate[date]!;
          if (list.isEmpty) {
            await activeLocBox.delete(date);
            print('🎉 REPO: All locations for $date synced & deleted.');
          } else {
            await activeLocBox.put(date, {'location': list});
          }
        }
      }
      return {
        'success': isSyncSuccess,
        'failed': failedCoordinates.map((c) => c['entry']).toList(),
      };
    } finally {
      _isSyncing = false;
    }
  }

  /// Internal Isolate task to filter locations chronologically
  static Map<String, List<dynamic>> _filterLocations(
    List<dynamic> locations,
    int? upToTimestamp,
    int? fromTimestamp,
  ) {
    final sync = <dynamic>[];
    final keep = <dynamic>[];

    for (final loc in locations) {
      if (loc is! Map) continue;

      final locTime = loc['time'] as int?;
      if (locTime == null) {
        sync.add(loc);
        continue;
      }

      final isAfterClockIn = fromTimestamp == null || locTime >= fromTimestamp;
      final isBeforeClockOut =
          upToTimestamp == null || locTime <= upToTimestamp;

      if (isAfterClockIn && isBeforeClockOut) {
        sync.add(loc);
      } else {
        keep.add(loc);
      }
    }
    return {'toSync': sync, 'toKeep': keep};
  }

  /// Call the actual location update endpoint
  Future<bool> _uploadLocationChunkApi(List<dynamic> chunk) async {
    try {
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

      if (body.isEmpty) return true;

      final jwtToken = AuthLocalRepository.instance.getJwtToken();
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await dio.post<Map<String, dynamic>>(
        updateUserLocationUrl,
        data: FormData.fromMap(body),
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      return !(response.data?['error'] as bool? ?? true);
    } catch (e) {
      print('❌ : $e');
      return false;
    }
  }

  /// Compatibility stub for final clock-out flush
  Future<bool> syncToServer({int chunkSize = 500}) async {
    final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final result = await syncLocationsToServer(
      date: todayStr,
      chunkSize: chunkSize,
    );
    return result['success'] as bool? ?? false;
  }

  /// Initialize Hive box for location points
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(LocationPointAdapter().typeId)) {
      Hive.registerAdapter(LocationPointAdapter());
    }
    if (!Hive.isBoxOpen(kHiveBoxName)) {
      await Hive.openBox(kHiveBoxName);
    }
  }

  /// Close the Hive box
  static Future<void> close() async {
    if (Hive.isBoxOpen(kHiveBoxName)) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final lockFile = File('${dir.path}/${kHiveBoxName.toLowerCase()}.lock');
        if (!await lockFile.exists()) {
          await lockFile.create();
        }
      } catch (e) {
        print('⚠️ Failed to ensure Hive lock file exists before close: $e');
      }
      try {
        await Hive.box(kHiveBoxName).close();
      } catch (e) {
        print('❌ Hive close failed: $e');
      }
    }
  }

  /// Clear all location points from storage
  Future<void> clearAll() async {
    if (!Hive.isBoxOpen(kHiveBoxName)) return;
    await _box.clear();
  }

  List<LocationPoint> getAllPoints() {
    if (!Hive.isBoxOpen(kHiveBoxName)) return [];
    // Helper to return flattened LocationPoint objects from all date keys
    final list = <LocationPoint>[];
    final box = _box;
    for (final key in box.keys) {
      final data = box.get(key);
      print(
        '📦 REPO getAllPoints: Retrieved location data from Hive for key $key: $data',
      );
      if (data is Map && data['location'] is List) {
        for (final loc in data['location'] as Iterable) {
          if (loc is Map) {
            list.add(
              LocationPoint(
                latitude: (loc['lat'] as num).toDouble(),
                longitude: (loc['long'] as num).toDouble(),
                timestamp: DateTime.fromMillisecondsSinceEpoch(
                  loc['time'] as int,
                ),
                date: loc['date'] as String? ?? '',
              ),
            );
          }
        }
      }
    }
    return list;
  }

  Future<void> closeBox() async {
    await close();
  }
}
