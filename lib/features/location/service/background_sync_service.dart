import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/utils/connectivity.dart';
import 'package:omkar_sale/features/location/service/manual_sync_service.dart';

class EntryRef {
  final String dateKey;
  final int index;
  final Map<String, dynamic> entry;

  EntryRef({required this.dateKey, required this.index, required this.entry});
}

class BackgroundSyncService {
  BackgroundSyncService._();
  static final BackgroundSyncService instance = BackgroundSyncService._();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<void> _syncChain = Future.value();

  Future<void>? _activeSync;
  Future<void>? get activeSyncFuture => _activeSync;
  StreamSubscription? _connectivitySubscription;
  bool _initialized = false;

  Future<Box<dynamic>> _getClockInOutBox() async {
    return Hive.isBoxOpen(ClockInOutRepository.kClockInOutBoxName)
        ? Hive.box<dynamic>(ClockInOutRepository.kClockInOutBoxName)
        : await Hive.openBox<dynamic>(ClockInOutRepository.kClockInOutBoxName);
  }

  /// Starts background sync checking and network change listeners.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Listen for internet changes and trigger sync when connection is restored
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (_) => _triggerSync(),
    );

    print(
      '🚀 [BackgroundSyncService] Initialized and listening for connection.',
    );
  }

  /// Cancels stream subscriptions when service is stopped.
  void dispose() {
    _connectivitySubscription?.cancel();
    _initialized = false;
  }

  /// Performs the actual synchronization run.
  Future<void> _runSyncDirectly() async {
    final hasInternet = await InternetConnectivity.checkInternet();
    if (!hasInternet) return;

    // Prevent conflict: If manual sync is currently active, abort background sync
    // if (ManualSyncService.instance.isManualSyncing) {
    //   print(
    //     '⚠️ [BackgroundSyncService] Manual sync is active. Aborting background sync.',
    //   );
    //   return;
    // }

    _isSyncing = true;
    _activeSync = syncAllPendingData();
    try {
      await _activeSync;
    } catch (e) {
      print('[BackgroundSyncService] Error during sync: $e');
    } finally {
      _isSyncing = false;
      _activeSync = null;
    }
  }

  bool _syncPending = false;

  /// Triggers a sync run sequentially.
  void _triggerSync() {
    if (_syncPending || _isSyncing)
      return; // Already queued or running — drop this trigger
    _syncPending = true;
    _syncChain = _syncChain
        .then((_) async {
          _syncPending = false;
          await _runSyncDirectly();
        })
        .catchError((Object e) {
          _syncPending = false;
          log("[BackgroundSyncService] Chained sync error: $e");
        });
  }

  /// Allows manual invocation of the sync process.
  Future<void> forceManualSync() async {
    print('🔄 [BackgroundSyncService] Manual sync requested.');
    await _runSyncDirectly();
  }

  /// Core sync logic: collects entries, sorts chronologically, pairs them, and flushes locations.
  Future<void> syncAllPendingData() async {
    final box = await _getClockInOutBox();

    // STEP 1: Find all Hive keys matching date format (dd-MM-yyyy)
    final dateKeys = box.keys.where((key) {
      if (key is! String) return false;
      final parts = key.split('-');
      return parts.length == 3 && parts.every((p) => int.tryParse(p) != null);
    }).toList();

    if (dateKeys.isEmpty) return;

    // STEP 2: Collect all entries from those dates with their original indices
    final List<EntryRef> allRefs = [];
    for (final dateKey in dateKeys) {
      final activeBox = await _getClockInOutBox();
      final list = activeBox.get(dateKey);
      if (list is List) {
        for (int i = 0; i < list.length; i++) {
          final item = list[i];
          if (item is Map) {
            allRefs.add(
              EntryRef(
                dateKey: dateKey as String,
                index: i,
                entry: Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      }
    }

    // STEP 3: Sort all entries chronologically by their timestamp
    allRefs.sort((a, b) {
      final timeA = a.entry['time'] as int? ?? 0;
      final timeB = b.entry['time'] as int? ?? 0;
      return timeA.compareTo(timeB);
    });

    // STEP 4: Pair matching 'in' and 'out' entries chronologically and sync them
    int i = 0;
    while (i < allRefs.length) {
      final currentRef = allRefs[i];
      final currentType = currentRef.entry['type'] as String?;

      if (currentType == 'in') {
        if (i + 1 < allRefs.length) {
          final nextRef = allRefs[i + 1];
          final nextType = nextRef.entry['type'] as String?;

          // If a complete 'in' and 'out' pair is found, process the synchronization
          if (nextType == 'out') {
            final bool pairProcessed = await _syncPair(currentRef, nextRef);
            if (!pairProcessed) break; // Halt if any pair fails
            i += 2;
            continue;
          }
        }
        // Last entry is 'in' (active shift, has no matching 'out' yet).
        break;
      } else {
        // Skip out-of-order 'out' entries
        i++;
      }
    }

    // STEP 5: Cleanup Pass: Delete completed historical dates from Hive.
    await cleanCompletedDates();
  }

  // Remove old completed shift dates
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

      // Check:
      // 1. All entries synced
      // 2. Last entry is clock-out
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
      print('🧹 [BackgroundSyncService] Cleaned up historical date: $key');
    }
  }

  /// Syncs an individual matched 'in' and 'out' pair.
  Future<bool> _syncPair(EntryRef inRef, EntryRef outRef) async {
    final repository = ClockInOutRepository();

    // 1. Sync the 'in' entry
    bool inSync = inRef.entry['isSync'] as bool? ?? false;
    if (!inSync) {
      inSync = await repository.clockInApiDirectly(inRef.entry);
      inRef.entry['isSync'] = inSync;

      // Update entry in Hive
      final box = await _getClockInOutBox();
      final list = List<dynamic>.from(
        box.get(inRef.dateKey) as Iterable? ?? [],
      );
      if (inRef.index < list.length) {
        list[inRef.index] = inRef.entry;
        await box.put(inRef.dateKey, list);
      }

      // If the 'in' API fails, stop syncing further pairs
      if (!inSync) return false;
    }

    // 2. Sync location coordinates recorded in the shift interval (handles rollover dates)
    final bool locSyncSuccess = await _syncLocationsForPair(
      inRef.entry,
      outRef.entry,
    );
    if (!locSyncSuccess) {
      print(
        '⚠️ [BackgroundSyncService] Location sync failed for pair. Halting out sync.',
      );
      return false;
    }

    // 3. Sync the corresponding 'out' entry
    bool outSync = outRef.entry['isSync'] as bool? ?? false;
    if (!outSync) {
      outSync = await repository.clockOutApiDirectly(outRef.entry);
      outRef.entry['isSync'] = outSync;

      // Update entry in Hive to store synced state of clock-out
      final box = await _getClockInOutBox();
      final list = List<dynamic>.from(
        box.get(outRef.dateKey) as Iterable? ?? [],
      );
      if (outRef.index < list.length) {
        list[outRef.index] = outRef.entry;
        await box.put(outRef.dateKey, list);
      }

      if (!outSync) return false;
    }

    return true;
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

    // Collect all date strings spanned by this shift
    final List<String> datesToSync = [];
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final DateTime endDay = DateTime(endDate.year, endDate.month, endDate.day);

    while (!current.isAfter(endDay)) {
      datesToSync.add(DateFormat('dd-MM-yyyy').format(current));
      current = current.add(const Duration(days: 1));
    }

    bool allSuccess = true;
    for (final syncDate in datesToSync) {
      final syncResult = await LocationRepository().syncLocationsToServer(
        date: syncDate,
        upToTimestamp: upToTimestamp,
        fromTimestamp: fromTimestamp,
        chunkSize: 500,
      );
      if (syncResult['success'] != true) {
        allSuccess = false;
      }
    }
    return allSuccess;
  }
}
