import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:workmanager/workmanager.dart';

/// WorkManager periodic watchdog. Runs in headless isolate every ~15 min,
/// independent of app process. Survives OS kills.
///
/// Flow:
///   1. Open shift_config Hive box.
///   2. If shift active → ensure bg service is running.
///
/// Cancel on clock-out (see ClockInOutCubit.clockOut).
class TrackerWatchdog {
  TrackerWatchdog._();

  static const String _taskName = 'tracelet_watchdog_periodic';

  // Stagger 5 periodic tasks with 3-min offsets. Android per-task minimum
  // is 15 min; 5 staggered tasks give effective ~3 min poll cadence.
  // A: 0,15,30...  B: 3,18,33...  C: 6,21,36...  D: 9,24,39...  E: 12,27,42...
  static const List<({String id, Duration delay})> _workers = [
    (id: 'tracelet_watchdog_a', delay: Duration.zero),
    (id: 'tracelet_watchdog_b', delay: Duration(minutes: 3)),
    (id: 'tracelet_watchdog_c', delay: Duration(minutes: 6)),
    (id: 'tracelet_watchdog_d', delay: Duration(minutes: 9)),
    (id: 'tracelet_watchdog_e', delay: Duration(minutes: 12)),
  ];

  /// Call once from main() / initializeApp().
  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  /// Call after successful clock-in. Registers periodic workers.
  static Future<void> schedulePeriodic() async {
    if (!Platform.isAndroid) return;
    for (final w in _workers) {
      await Workmanager().registerPeriodicTask(
        w.id,
        _taskName,
        frequency: const Duration(minutes: 15), // Android minimum.
        initialDelay: w.delay,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 1),
      );
    }
    print('🐕 WATCHDOG: scheduled ${_workers.length} staggered workers (15min cycle, ~3min effective)');
  }

  /// Call on clock-out.
  static Future<void> cancel() async {
    if (!Platform.isAndroid) return;
    for (final w in _workers) {
      await Workmanager().cancelByUniqueName(w.id);
    }
    print('🐕 WATCHDOG: cancelled all workers');
  }
}

/// Top-level entry point — must NOT capture Flutter state.
/// Runs in a separate isolate spawned by WorkManager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🐕 WATCHDOG: task fired ($task)');
    try {
      // Need Hive in this isolate too.
      await Hive.initFlutter();
      final box = await Hive.openBox<dynamic>('shift_config');
      final isActive = (box.get('isActive') as bool?) ?? false;

      if (!isActive) {
        print('🐕 WATCHDOG: shift not active — skipping restart');
        return Future.value(true);
      }

      // Primary liveness probe: bg service running?
      // Stationary phone may not emit GPS fixes for long stretches,
      // so timestamp alone is unreliable — process-running is authoritative.

      // Step 1: Freshness probe via Hive heartbeat (no engine spawn).
      final appBox = await Hive.openBox<dynamic>('app_preferences');
      final lastStreamMs = appBox.get('lastStreamEpochMs') as int?;
      final lastFixMs = appBox.get('lastFixEpochMs') as int?;
      final heartbeatMs = lastStreamMs ?? lastFixMs;

      if (heartbeatMs != null) {
        final ageMs = DateTime.now().millisecondsSinceEpoch - heartbeatMs;
        final ageMin = (ageMs / 60000).toStringAsFixed(1);
        print('🐕 WATCHDOG: last stream heartbeat $ageMin min ago');
        if (ageMs < 5 * 60 * 1000) {
          print('🐕 WATCHDOG: bg stream alive — no-op');
          return Future.value(true);
        }
        // Stream stale: nudge bg isolate to restart its position stream,
        // and ensure service running. If service was killed, startService
        // brings it back; if alive, restartStream handler fires.
        print('🐕 WATCHDOG: bg stream stale → invoke restartStream + startService');
        try {
          FlutterBackgroundService().invoke('restartStream');
        } on Exception catch (e) {
          print('⚠️ WATCHDOG: invoke(restartStream) failed: $e');
        }
        await FlutterBackgroundService().startService();
        return Future.value(true);
      }

      // Step 2: no heartbeat at all — fallback to process-running probe.
      final svcAlive = await FlutterBackgroundService().isRunning();
      if (svcAlive) {
        print('🐕 WATCHDOG: bg service alive (no heartbeat yet) — no-op');
        return Future.value(true);
      }
      print('🐕 WATCHDOG: bg service dead → restarting');

      // Bg service was dead (liveness check above). Start it. The bg
      // isolate's onShiftServiceStart reads shift_config Hive box on
      // boot — no `invoke('init', ...)` from worker needed.
      await FlutterBackgroundService().startService();
      print('🐕 WATCHDOG: bg service startService() invoked');
    } on Exception catch (e) {
      print('⚠️ WATCHDOG: task failed: $e');
    }
    return Future.value(true);
  });
}
