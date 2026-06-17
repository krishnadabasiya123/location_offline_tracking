import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/location/service/location_service.dart';
import 'package:omkar_sale/features/location/service/tracker_watchdog.dart';
import 'package:omkar_sale/features/location/service/background_sync_service.dart';
import 'package:omkar_sale/features/location/service/manual_sync_service.dart';
import 'package:omkar_sale/utils/notification_utils/notification_utils.dart';

// ---------------------------------------------------------------------------
// CLOCK IN/OUT STATE
// ---------------------------------------------------------------------------
@immutable
abstract class ClockInOutState extends Equatable {}

class ClockInOutInitial extends ClockInOutState {
  @override
  List<Object?> get props => [];
}

class ClockInOutInProgress extends ClockInOutState {
  @override
  List<Object?> get props => [];
}

class ClockInOuSuccess extends ClockInOutState {
  ClockInOuSuccess({required this.isClockIn});
  final bool isClockIn;

  @override
  List<Object?> get props => [isClockIn];
}

class ClockInOutFetchFailure extends ClockInOutState {
  ClockInOutFetchFailure({required this.exception});

  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

// ---------------------------------------------------------------------------
// CLOCK IN/OUT CUBIT
// ---------------------------------------------------------------------------
class ClockInOutCubit extends Cubit<ClockInOutState> {
  ClockInOutCubit() : super(ClockInOutInitial());

  final ClockInOutRepository _repository = ClockInOutRepository();
  final LocationRepository _locationRepository = LocationRepository();

  bool _isClockedIn = false;
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // INITIALIZATION — call this from initState() in your widget
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    emit(ClockInOutInProgress());

    try {
      _isClockedIn = SettingLocalRepository.instance.getClockedIn();
      log('🔁 Restored clock state: isClockedIn=$_isClockedIn');

      if (_isClockedIn) {
        unawaited(
          NotificationService.instance.showLocalNotification(
            title: 'Shift active',
            body: 'Your shift is still running. Location tracking is active.',
          ),
        );
        if (!LocationTracker.instance.isRunning) {
          log('🔁 Resuming LocationTracker after app restart.');
          await LocationTracker.instance.start();
        }
      }

      emit(ClockInOuSuccess(isClockIn: _isClockedIn));
    } on Exception catch (e) {
      log('⚠️ Could not restore clock state: $e');
      emit(ClockInOutInitial());
    }
  }

  // ---------------------------------------------------------------------------
  // PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  Map<String, String> _positionToMap(Position position) => {
    'latitude': position.latitude.toString(),
    'longitude': position.longitude.toString(),
  };

  void _emitFailure(String message) {
    emit(
      ClockInOutFetchFailure(
        exception: ApiException(errorMessageKey: message),
      ),
    );
  }

  Future<void> _persistClockState(bool isClockedIn) async {
    try {
      await SettingLocalRepository.instance.setClockedIn(isClockedIn);
      log('💾 Persisted clock state: isClockedIn=$isClockedIn');
    } catch (e) {
      log('⚠️ Could not persist clock state: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // LOCATION HELPER
  // ---------------------------------------------------------------------------

  Future<Map<String, String>?> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        log('❌ Master GPS switch is turned off.');
        throw const ApiException(
          errorMessageKey:
              'Your device GPS is turned off. Please enable it in your quick settings.',
        );
      }

      log('📍 Checking location permission...');

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        log('⚠️ Permission denied — requesting...');
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        log('❌ Permission permanently denied.');
        throw const ApiException(
          errorMessageKey:
              'Location permission is permanently denied. Please enable it from device Settings.',
        );
      }

      log('📍 Permission granted. Getting current position (20s timeout)...');

      final position = await _fetchPositionWithFallback();
      if (position != null) {
        log('✅ Got position: ${position.latitude}, ${position.longitude}');
        return _positionToMap(position);
      }

      log(
        '❌ No location available — GPS timed out and no last known position.',
      );
      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      log('❌ Unexpected exception in _getCurrentLocation: $e');
      return null;
    }
  }

  Future<Position?> _fetchPositionWithFallback() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 20));
    } catch (_) {
      log('⚠️ GPS timed out or failed. Trying last known position...');
      return Geolocator.getLastKnownPosition();
    }
  }

  // ---------------------------------------------------------------------------
  // CLOCK IN
  // ---------------------------------------------------------------------------

  Future<void> clockIn() async {
    if (_isLoading) {
      log('⚠️ Clock in already in progress — ignoring duplicate tap.');
      return;
    }
    _isLoading = true;
    emit(ClockInOutInProgress());

    try {
      final currentLocation = await _getCurrentLocation();

      if (currentLocation == null) {
        _emitFailure(
          'Could not get GPS signal. Step outside, wait a few seconds, and try again.',
        );
        return;
      }

      log('📤 Clocking in with location: $currentLocation');

      final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final entry = {
        "type": "in",
        "time": timestamp,
        "lat": currentLocation["latitude"],
        "long": currentLocation["longitude"],
      };

      await _repository.setClockInOut(date: todayStr, entry: entry);

      // Clean completed historical dates immediately on new clock-in (handles offline)
      await BackgroundSyncService.instance.cleanCompletedDates();

      await LocationTracker.instance.start();

      _isClockedIn = true;
      await _persistClockState(true);

      // Persist shift_config so headless watchdog isolate can read it.
      final token = AuthLocalRepository.instance.getJwtToken();
      final interval = SettingLocalRepository.instance
          .getLocationUpdateInterval();
      await SettingLocalRepository.instance.saveShiftConfig(
        token: token,
        interval: interval,
        isActive: true,
      );
      await TrackerWatchdog.schedulePeriodic();

      log('✅ Clock in successful.');

      // Heads-up alert confirming the shift started.
      await NotificationService.instance.showLocalNotification(
        title: 'Shift started',
        body: 'You are clocked in. Location tracking is active.',
      );

      emit(ClockInOuSuccess(isClockIn: false));
    } on ApiException catch (e) {
      log('❌ ApiException during clock in: ${e.errorMessageKey}');
      emit(ClockInOutFetchFailure(exception: e));
    } catch (e) {
      log('❌ Unexpected error during clock in: $e');
      _emitFailure(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  // ---------------------------------------------------------------------------
  // CLOCK OUT
  // ---------------------------------------------------------------------------

  Future<void> clockOut() async {
    if (_isLoading) {
      log('⚠️ Clock out already in progress — ignoring duplicate tap.');
      return;
    }
    _isLoading = true;
    emit(ClockInOutInProgress());

    // Cancel watchdog + flag shift inactive FIRST so any in-flight worker
    // exits early before tracker.stop() runs. Prevents race where worker
    // restarts tracelet during shutdown, leaving notification stuck.
    await SettingLocalRepository.instance.setShiftActive(false);
    await TrackerWatchdog.cancel();

    // Always stop tracking first, regardless of what happens next
    await LocationTracker.instance.stop();
    log('🛑 Location tracker stopped.');

    // Clear all app notifications (FGS persistent + scheduled).
    try {
      await AwesomeNotifications().cancelAll();
      await AwesomeNotifications().dismissAllNotifications();
      log('🔕 All Omkar notifications cleared.');
    } catch (e) {
      log('⚠️ Notification cancel failed: $e');
    }

    // Refresh main isolate's Hive view
    try {
      await LocationRepository.close();
    } catch (e) {
      log('⚠️ Hive close skipped (already closed by bg isolate): $e');
    }
    try {
      await LocationRepository.init();
      log('🔄 Location Hive box refreshed for clock-out read.');
    } catch (e) {
      log('⚠️ Hive init failed: $e');
    }

    try {
      final currentLocation = await _getCurrentLocation();
      if (currentLocation == null) {
        _emitFailure('Could not get GPS signal for Clock Out.');
        return;
      }

      final int outTime = DateTime.now().millisecondsSinceEpoch;
      final outEntry = {
        "type": "out",
        "time": outTime,
        "lat": currentLocation["latitude"],
        "long": currentLocation["longitude"],
        "isSync": false,
      };

      if (!Hive.isBoxOpen(ClockInOutRepository.kClockInOutBoxName)) {
        await Hive.openBox(ClockInOutRepository.kClockInOutBoxName);
      }
      final box = Hive.box(ClockInOutRepository.kClockInOutBoxName);

      // Determine the correct date key to append the clock-out entry to.
      // If the corresponding clock-in was on a previous date (rollover shift),
      // we must append this clock-out to that previous date's key so they remain paired.
      final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
      String targetDateKey = todayStr;

      // Find all Hive keys matching date format (dd-MM-yyyy)
      final dateKeys = box.keys.where((key) {
        if (key is! String) return false;
        final parts = key.split('-');
        return parts.length == 3 && parts.every((p) => int.tryParse(p) != null);
      }).toList();

      final List<Map<String, dynamic>> allEntriesWithDate = [];
      for (final dateKey in dateKeys) {
        final list = box.get(dateKey);
        if (list is List) {
          for (int i = 0; i < list.length; i++) {
            final item = list[i];
            if (item is Map) {
              allEntriesWithDate.add({
                'dateKey': dateKey,
                'index': i,
                'entry': Map<String, dynamic>.from(item),
              });
            }
          }
        }
      }
      Map<String, dynamic>? lastInEntry;
      int lastInEntryIndex = -1;

      if (allEntriesWithDate.isNotEmpty) {
        // Sort chronologically by entry time
        allEntriesWithDate.sort((a, b) {
          final timeA = (a['entry'] as Map)['time'] as int? ?? 0;
          final timeB = (b['entry'] as Map)['time'] as int? ?? 0;
          return timeA.compareTo(timeB);
        });

        // The last entry in chronological order is the active clock-in
        final lastItem = allEntriesWithDate.last;
        final lastType = (lastItem['entry'] as Map)['type'] as String?;
        if (lastType == 'in') {
          targetDateKey = lastItem['dateKey'] as String;
          lastInEntry = lastItem['entry'] as Map<String, dynamic>;
          lastInEntryIndex = lastItem['index'] as int;
        }
      }

      _isClockedIn = false;
      await _persistClockState(false);

      // Trigger the manual sync process asynchronously
      if (lastInEntry != null && lastInEntryIndex != -1) {
        // Trigger the manual sync process asynchronously in the background without blocking the UI
        ManualSyncService.instance.syncClockOut(
          outEntry: outEntry,
          targetDateKey: targetDateKey,
          lastInEntry: lastInEntry,
          lastInEntryIndex: lastInEntryIndex,
        );
      } else {
        // Fallback: If no active in entry was found (e.g. DB cleared), save the out entry to Hive directly
        final List<dynamic> existingEntries = List<dynamic>.from(
          box.get(targetDateKey) as Iterable? ?? [],
        );
        existingEntries.add(outEntry);
        await box.put(targetDateKey, existingEntries);
      }

      log('✅ Clock out successful.');
      emit(ClockInOuSuccess(isClockIn: true));
    } on ApiException catch (e) {
      log('❌ ApiException during clock out: ${e.errorMessageKey}');
      emit(ClockInOutFetchFailure(exception: e));
    } catch (e) {
      log('❌ Unexpected error during clock out: $e');
      _emitFailure(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  // ---------------------------------------------------------------------------
  // LEGACY / UTILITY
  // ---------------------------------------------------------------------------

  Future<void> setClockInOut({required bool isClockIn}) async {
    if (isClockIn) {
      await clockOut();
    } else {
      await clockIn();
    }
  }

  @override
  Future<void> close() async {
    try {
      await _locationRepository.closeBox();
      log('📦 Hive box closed cleanly.');
    } catch (e) {
      log('⚠️ Error closing Hive box: $e');
    }
    await super.close();
  }

  bool get isClockedIn => _isClockedIn;
}
