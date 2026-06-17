// import 'dart:async';
// import 'package:omkar_sale/core/app/all_import_file.dart';
// import 'package:omkar_sale/utils/connectivity.dart';
// import 'package:omkar_sale/features/location/service/background_sync_service.dart';

// class ManualSyncService {
//   ManualSyncService._();
//   static final ManualSyncService instance = ManualSyncService._();

//   bool _isManualSyncing = false;
//   bool get isManualSyncing => _isManualSyncing;

//   /// Allows manual invocation of the sync process (e.g. from the Clock-Out button click).
//   Future<void> forceManualSync() async {
//     print('🔄 [ManualSyncService] Manual sync requested.');

//     final hasInternet = await InternetConnectivity.checkInternet();
//     if (!hasInternet) {
//       print('⚠️ [ManualSyncService] No internet connection. Aborting sync.');
//       return;
//     }

//     // Prevent conflict: If background sync is currently running, wait for it to complete
//     if (BackgroundSyncService.instance.isSyncing &&
//         BackgroundSyncService.instance.activeSyncFuture != null) {
//       print('⏳ [ManualSyncService] Background sync is active. Awaiting completion before running manual sync...');
//       await BackgroundSyncService.instance.activeSyncFuture;
//     }

//     if (_isManualSyncing) return;
//     _isManualSyncing = true;

//     try {
//       await syncAllPendingData();
//     } catch (e) {
//       print('❌ [ManualSyncService] Error during manual sync: $e');
//     } finally {
//       _isManualSyncing = false;
//     }
//   }

//   /// Core sync logic: collects entries, sorts chronologically, pairs them, and flushes locations.
//   Future<void> syncAllPendingData() async {
//     if (!Hive.isBoxOpen(ClockInOutRepository.kClockInOutBoxName)) {
//       await Hive.openBox(ClockInOutRepository.kClockInOutBoxName);
//     }
//     final box = Hive.box(ClockInOutRepository.kClockInOutBoxName);

//     // STEP 1: Find all Hive keys matching date format (dd-MM-yyyy)
//     final dateKeys = box.keys.where((key) {
//       if (key is! String) return false;
//       final parts = key.split('-');
//       return parts.length == 3 && parts.every((p) => int.tryParse(p) != null);
//     }).toList();

//     if (dateKeys.isEmpty) return;

//     // STEP 2: Collect all entries from those dates with their original indices
//     final List<EntryRef> allRefs = [];
//     for (final dateKey in dateKeys) {
//       final list = box.get(dateKey);
//       if (list is List) {
//         for (int i = 0; i < list.length; i++) {
//           final item = list[i];
//           if (item is Map) {
//             allRefs.add(
//               EntryRef(
//                 dateKey: dateKey as String,
//                 index: i,
//                 entry: Map<String, dynamic>.from(item),
//               ),
//             );
//           }
//         }
//       }
//     }

//     // STEP 3: Sort all entries chronologically by their timestamp
//     allRefs.sort((a, b) {
//       final timeA = a.entry['time'] as int? ?? 0;
//       final timeB = b.entry['time'] as int? ?? 0;
//       return timeA.compareTo(timeB);
//     });

//     // STEP 4: Pair matching 'in' and 'out' entries chronologically and sync them
//     int i = 0;
//     while (i < allRefs.length) {
//       final currentRef = allRefs[i];
//       final currentType = currentRef.entry['type'] as String?;

//       if (currentType == 'in') {
//         if (i + 1 < allRefs.length) {
//           final nextRef = allRefs[i + 1];
//           final nextType = nextRef.entry['type'] as String?;

//           // If a complete 'in' and 'out' pair is found, process the synchronization
//           if (nextType == 'out') {
//             final bool pairProcessed = await _syncPair(currentRef, nextRef);
//             if (!pairProcessed) break; // Halt if any pair fails
//             i += 2;
//             continue;
//           }
//         }
//         // Last entry is 'in' (active shift, has no matching 'out' yet).
//         break;
//       } else {
//         // Skip out-of-order 'out' entries
//         i++;
//       }
//     }

//     // STEP 5: Cleanup Pass: Delete completed historical dates from Hive.
//     await cleanCompletedDates();
//   }

//   /// Cleans completed historical dates from Hive immediately.
//   Future<void> cleanCompletedDates() async {
//     if (!Hive.isBoxOpen(ClockInOutRepository.kClockInOutBoxName)) return;
//     final box = Hive.box(ClockInOutRepository.kClockInOutBoxName);
//     final formatter = DateFormat('dd-MM-yyyy');

//     // Get all valid date keys
//     final List<String> dateKeys = box.keys.whereType<String>().where((key) {
//       final parts = key.split('-');
//       return parts.length == 3 && parts.every((e) => int.tryParse(e) != null);
//     }).toList();

//     if (dateKeys.isEmpty) return;

//     // Sort dates ascending
//     dateKeys.sort((a, b) => formatter.parse(a).compareTo(formatter.parse(b)));

//     final List<String> datesToDelete = [];

//     for (int i = 0; i < dateKeys.length; i++) {
//       final currentKey = dateKeys[i];
//       final currentList = box.get(currentKey);

//       if (currentList is! List || currentList.isEmpty) {
//         continue;
//       }

//       final entries = currentList
//           .map((e) => Map<String, dynamic>.from(e as Map))
//           .toList();

//       // Check: All entries synced and last is clock-out
//       final bool canClean =
//           entries.every((e) => e['isSync'] == true) &&
//           entries.last['type'] == 'out';

//       if (!canClean) continue;

//       bool hasNextClockIn = false;

//       // Check future dates for clock-in
//       for (int j = i + 1; j < dateKeys.length; j++) {
//         final nextList = box.get(dateKeys[j]);

//         if (nextList is List &&
//             nextList.any((e) => e is Map && e['type'] == 'in')) {
//           hasNextClockIn = true;
//           break;
//         }
//       }

//       if (hasNextClockIn) {
//         datesToDelete.add(currentKey);
//       }
//     }

//     // Delete old completed dates
//     for (final key in datesToDelete) {
//       await box.delete(key);
//       print('🧹 [ManualSyncService] Cleaned up historical date: $key');
//     }
//   }

//   /// Syncs an individual matched 'in' and 'out' pair.
//   Future<bool> _syncPair(EntryRef inRef, EntryRef outRef) async {
//     final repository = ClockInOutRepository();
//     final box = Hive.box(ClockInOutRepository.kClockInOutBoxName);

//     // 1. Sync the 'in' entry
//     bool inSync = inRef.entry['isSync'] as bool? ?? false;
//     if (!inSync) {
//       inSync = await repository.clockInApiDirectly(inRef.entry);
//       inRef.entry['isSync'] = inSync;

//       // Update entry in Hive
//       final list = List<dynamic>.from(box.get(inRef.dateKey) as Iterable? ?? []);
//       if (inRef.index < list.length) {
//         list[inRef.index] = inRef.entry;
//         await box.put(inRef.dateKey, list);
//       }

//       if (!inSync) return false;
//     }

//     // 2. Sync locations
//     final bool locSyncSuccess = await _syncLocationsForPair(
//       inRef.entry,
//       outRef.entry,
//     );
//     if (!locSyncSuccess) {
//       print('⚠️ [ManualSyncService] Location sync failed. Halting out sync.');
//       return false;
//     }

//     // 3. Sync the corresponding 'out' entry
//     bool outSync = outRef.entry['isSync'] as bool? ?? false;
//     if (!outSync) {
//       outSync = await repository.clockOutApiDirectly(outRef.entry);
//       outRef.entry['isSync'] = outSync;

//       // Update entry in Hive
//       final list = List<dynamic>.from(box.get(outRef.dateKey) as Iterable? ?? []);
//       if (outRef.index < list.length) {
//         list[outRef.index] = outRef.entry;
//         await box.put(outRef.dateKey, list);
//       }

//       if (!outSync) return false;
//     }

//     return true;
//   }

//   /// Identifies and syncs coordinates recorded on all days spanned by the shift
//   Future<bool> _syncLocationsForPair(
//     Map<String, dynamic> inEntry,
//     Map<String, dynamic> outEntry,
//   ) async {
//     final int? fromTimestamp = inEntry['time'] as int?;
//     final int? upToTimestamp = outEntry['time'] as int?;

//     if (fromTimestamp == null || upToTimestamp == null) return true;

//     final DateTime startDate = DateTime.fromMillisecondsSinceEpoch(fromTimestamp);
//     final DateTime endDate = DateTime.fromMillisecondsSinceEpoch(upToTimestamp);

//     final List<String> datesToSync = [];
//     DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
//     final DateTime endDay = DateTime(endDate.year, endDate.month, endDate.day);

//     while (!current.isAfter(endDay)) {
//       datesToSync.add(DateFormat('dd-MM-yyyy').format(current));
//       current = current.add(const Duration(days: 1));
//     }

//     bool allSuccess = true;
//     for (final syncDate in datesToSync) {
//       final syncResult = await LocationRepository().syncLocationsToServer(
//         date: syncDate,
//         upToTimestamp: upToTimestamp,
//         fromTimestamp: fromTimestamp,
//         chunkSize: 500,
//       );
//       if (syncResult['success'] != true) {
//         allSuccess = false;
//       }
//     }
//     return allSuccess;
//   }
// }

import 'dart:async';
import 'dart:developer' as developer;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/location/repository/location_repository.dart';
import 'package:omkar_sale/utils/connectivity.dart';

class ManualSyncService {
  ManualSyncService._();
  static final ManualSyncService instance = ManualSyncService._();

  bool _isManualSyncing = false;
  bool get isManualSyncing => _isManualSyncing;

  String clockInOutDataBox = 'clockInOutDataBox';
  String locationDataBox = 'locationDataBox';

  Future<Box<dynamic>> _getClockInOutBox() async {
    return Hive.isBoxOpen(clockInOutDataBox)
        ? Hive.box<dynamic>(clockInOutDataBox)
        : await Hive.openBox<dynamic>(clockInOutDataBox);
  }

  /// Syncs the clock-out event immediately if internet is available.
  /// If offline, it saves the out entry to Hive.
  Future<void> syncClockOut({
    required Map<String, dynamic> outEntry,
    required String targetDateKey,
    required Map<String, dynamic> lastInEntry,
    required int lastInEntryIndex,
  }) async {
    final hasInternet = await InternetConnectivity.checkInternet();
    if (!hasInternet) {
      // Append the out entry to Hive as unsynced
      final activeBox = await _getClockInOutBox();

      final List<dynamic> existingEntries = List<dynamic>.from(
        activeBox.get(targetDateKey) as Iterable? ?? [],
      );

      existingEntries.add(outEntry);
      await activeBox.put(targetDateKey, existingEntries);
      return;
    }

    try {
      final repository = ClockInOutRepository();

      developer.log(
        "📤 [ManualSyncService] Clock-In data: $lastInEntry",
      );

      // 1. Sync the last 'in' entry if not already synced
      bool inSync = lastInEntry['isSync'] as bool? ?? false;
      if (!inSync) {
        inSync = await repository.clockInApiDirectly(lastInEntry);
        lastInEntry['isSync'] = inSync;

        // Update the last 'in' entry in Hive to mark it as synced
        final activeBox = await _getClockInOutBox();
        final list = List<dynamic>.from(
          activeBox.get(targetDateKey) as Iterable? ?? [],
        );
        if (lastInEntryIndex < list.length) {
          list[lastInEntryIndex] = lastInEntry;
          await activeBox.put(targetDateKey, list);
        }
      }

      // 2. Sync locations between 'in' entry time and current 'out' entry time
      final bool locSyncSuccess = await _syncLocationsForPair(
        lastInEntry,
        outEntry,
      );

      developer.log(
        "📤 [ManualSyncService] Clock-Out data: $outEntry",
      );

      // 3. Sync the 'out' entry to the server if previous steps succeeded
      bool outSync = false;
      if (inSync && locSyncSuccess) {
        outSync = await repository.clockOutApiDirectly(outEntry);
      }

      outEntry['isSync'] = outSync;

      // Append 'outEntry' (synced or unsynced depending on API success) to Hive
      final activeBox = await _getClockInOutBox();
      final List<dynamic> existingEntries = List<dynamic>.from(
        activeBox.get(targetDateKey) as Iterable? ?? [],
      );
      existingEntries.add(outEntry);
      await activeBox.put(targetDateKey, existingEntries);

      // Clean completed dates if the full day/period is completed and synced
      await cleanCompletedDates();
    } catch (e) {
      // Fallback: save outEntry as unsynced
      outEntry['isSync'] = false;
      final activeBox = await _getClockInOutBox();
      final List<dynamic> existingEntries = List<dynamic>.from(
        activeBox.get(targetDateKey) as Iterable? ?? [],
      );
      existingEntries.add(outEntry);
      await activeBox.put(targetDateKey, existingEntries);
    }
  }

  /// Cleans completed historical dates from Hive immediately.
  Future<void> cleanCompletedDates() async {
    final box = await _getClockInOutBox();
    final formatter = DateFormat('dd-MM-yyyy');

    // Get all valid date keys
    final List<String> dateKeys = box.keys.whereType<String>().where((key) {
      final parts = key.split('-');
      return parts.length == 3 && parts.every((e) => int.tryParse(e) != null);
    }).toList();

    if (dateKeys.isEmpty) return;

    // Sort dates ascending
    dateKeys.sort((a, b) => formatter.parse(a).compareTo(formatter.parse(b)));

    final List<String> datesToDelete = [];

    for (int i = 0; i < dateKeys.length; i++) {
      final currentKey = dateKeys[i];
      final activeBox = await _getClockInOutBox();
      final currentList = activeBox.get(currentKey);

      if (currentList is! List || currentList.isEmpty) {
        continue;
      }

      final entries = currentList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // Check: All entries synced and last is clock-out
      final bool canClean =
          entries.every((e) => e['isSync'] == true) &&
          entries.last['type'] == 'out';

      if (!canClean) continue;

      bool hasNextClockIn = false;

      // Check future dates for clock-in
      for (int j = i + 1; j < dateKeys.length; j++) {
        final nextList = activeBox.get(dateKeys[j]);

        if (nextList is List &&
            nextList.any((e) => e is Map && e['type'] == 'in')) {
          hasNextClockIn = true;
          break;
        }
      }

      if (hasNextClockIn) {
        datesToDelete.add(currentKey);
      }
    }

    // Delete old completed dates
    for (final key in datesToDelete) {
      final activeBox = await _getClockInOutBox();
      await activeBox.delete(key);
    }
  }

  /// Identifies and syncs coordinates recorded on all days spanned by the shift
  Future<bool> _syncLocationsForPair(
    Map<String, dynamic> inEntry,
    Map<String, dynamic> outEntry,
  ) async {
    final int? fromTimestamp = inEntry['time'] as int?;
    final int? upToTimestamp = outEntry['time'] as int?;

    if (fromTimestamp == null || upToTimestamp == null) return true;

    final DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
      fromTimestamp,
    );
    final DateTime endDate = DateTime.fromMillisecondsSinceEpoch(upToTimestamp);

    final List<String> datesToSync = [];
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final DateTime endDay = DateTime(endDate.year, endDate.month, endDate.day);

    while (!current.isAfter(endDay)) {
      datesToSync.add(DateFormat('dd-MM-yyyy').format(current));
      current = current.add(const Duration(days: 1));
    }

    bool allSuccess = true;
    for (final syncDate in datesToSync) {
      // Print exactly which location data points are going to be synced
      List<dynamic> coordinatesToSync = [];
      try {
        if (Hive.isBoxOpen(locationDataBox)) {
          await Hive.box(locationDataBox).close();
        }
        final locBox = await Hive.openBox(locationDataBox);
        final locBoxData = locBox.get(syncDate);

        final List<dynamic> allLocations = List<dynamic>.from(
          locBoxData['location'] as List<dynamic>,
        );
        coordinatesToSync = allLocations.where((loc) {
          if (loc is! Map) return false;
          final int? locTime = loc['time'] as int?;
          if (locTime == null) return true;
          final bool isAfterClockIn = locTime >= fromTimestamp;
          final bool isBeforeClockOut = locTime <= upToTimestamp;
          return isAfterClockIn && isBeforeClockOut;
        }).toList();
      } catch (_) {}

      final formattedCoords = coordinatesToSync.map((loc) {
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

      developer.log(
        "📤 [ManualSyncService] Syncing locations for date $syncDate. Data: $formattedCoords",
      );

      final syncResult = await LocationRepository().syncLocationsToServer(
        date: syncDate,
        upToTimestamp: upToTimestamp,
        fromTimestamp: fromTimestamp,
        chunkSize: 500,
      );
      if (!(syncResult['success'] as bool? ?? false)) {
        allSuccess = false;
      }
    }
    return allSuccess;
  }
}

/// Helper class to track a specific entry's value and its original position in Hive.
class EntryRef {
  final String dateKey;
  final int index;
  final Map<String, dynamic> entry;

  EntryRef({required this.dateKey, required this.index, required this.entry});
}
