# Location Tracking — Background Isolate Migration Design

**Date:** 2026-05-22  
**Status:** Approved

---

## Problem

`LocationTracker` (geolocator stream + filtering + Hive saves + heartbeat + API sync) runs in the **main Flutter isolate**. OPPO ColorOS (Android 14) kills the main isolate after screen lock ~2 min. `flutter_background_service`'s background isolate survives via `stopWithTask="false"` and WatchdogReceiver restart — but currently only shows a notification and does nothing useful.

Vivo (Android 16) works fine. OPPO does not.

---

## Solution

Move all location tracking logic into the `flutter_background_service` background isolate. The background service **is** the tracker. The main app only signals start/stop.

---

## Architecture

### Before
```
Main Flutter isolate (dies on OPPO)    Background isolate (survives)
────────────────────────────────────   ─────────────────────────────
LocationTracker                        onShiftServiceStart
├── Geolocator.getPositionStream()     └── Notification watchdog only
├── Accuracy/speed/jitter filters
├── LocationRepository.saveLocal()
├── Heartbeat Timer.periodic(60s)
└── API sync via Dio
```

### After
```
Main Flutter isolate                   Background isolate (survives OPPO)
────────────────────                   ──────────────────────────────────
LocationTracker (thin wrapper)         onShiftServiceStart
├── start() → invoke('init')           ├── Receive 'init' → token + interval
└── stop()  → invoke('stopService')    ├── Hive.init() + openBox()
                                       ├── Geolocator.getPositionStream()
ClockInOutCubit                        ├── Accuracy gate (≤50m)
└── unchanged — calls                  ├── Stale data gate (≤60s)
    LocationTracker.start/stop         ├── Silent gap reset (≥5 min)
                                       ├── Speed gate (≤70 m/s)
                                       ├── Jitter gate (<3m, speed<5m/s)
                                       ├── LocationRepository.saveLocal()
                                       ├── Heartbeat Timer.periodic(60s)
                                       ├── API sync (Dio + JWT)
                                       ├── Recovery poller (stream dead)
                                       └── Notification watchdog (3s)
```

---

## Data Flow

### Clock-in
1. `ClockInOutCubit.clockIn()` → `LocationTracker.start()`
2. `LocationTracker.start()` → `startShiftService(token, interval)`
3. `startShiftService()`:
   - Writes `shift_config` Hive box: `{token, interval, isActive: true}`
   - Starts background service: `FlutterBackgroundService().startService()`
   - Invokes: `service.invoke('init', {'token': token, 'interval': interval})`
4. `onShiftServiceStart` receives `init` → initializes Hive + starts geolocator

### Clock-out
1. `LocationTracker.stop()` → `service.invoke('stopService')`
2. Background service:
   - Cancels geolocator subscription
   - Final sync to server
   - Writes `shift_config.isActive = false`
   - Closes Hive location box
   - `service.stopSelf()`

### WatchdogReceiver restart (OPPO process kill)
1. OPPO kills entire process
2. WatchdogReceiver fires → restarts `BackgroundService`
3. `onShiftServiceStart` runs — no main app to send `init`
4. Background service reads `shift_config` Hive box directly
5. If `isActive == true` → resumes tracking with stored token + interval
6. If `isActive == false` → stops self (clock-out already happened)

---

## Key Technical Decisions

### Geolocator in background engine
Geolocator platform channel is registered via `GeneratedPluginRegistrant` in the background engine automatically. **Do NOT call `DartPluginRegistrant.ensureInitialized()`** — it re-registers `FlutterBackgroundServicePlugin` which the package explicitly removes, causing crashes.

### Hive initialization in background isolate
```dart
final dir = await getApplicationDocumentsDirectory();
Hive.init(dir.path);
// Register adapters, open boxes
```
`path_provider` works in background engine via `GeneratedPluginRegistrant`.

### shift_config Hive box (new)
Lightweight box storing shift state for WatchdogReceiver restart survival:
```dart
{
  'token': String,       // JWT for API calls
  'interval': int,       // sync interval minutes
  'isActive': bool,      // true = shift running
}
```

---

## Files Modified

| File | Change |
|---|---|
| `lib/features/location/service/shift_background_service.dart` | Add full tracker: geolocator, filters, Hive, heartbeat, sync, recovery poller |
| `lib/features/location/service/lib/.../location_service.dart` | Strip LocationTracker to thin wrapper — start/stop only |
| `lib/commons/cubits/clock_in_out_cubit.dart` | Pass token + interval to `startShiftService()` |
| `lib/commons/repositories/setting_local_repositories.dart` | Add `shift_config` box read/write methods |
| `lib/features/location/service/location_permission_guard.dart` | `onResume()` call kept — useful when app returns to foreground |

**No changes needed:**
- `location_repository.dart` — works from any isolate
- `api_config.dart` — Dio works without Flutter context  
- `AndroidManifest.xml` — already has correct permissions + service declarations
- `android/app/build.gradle.kts` — no change

---

## Error Handling

| Scenario | Handling |
|---|---|
| `init` message never arrives | 5s timeout → read `shift_config` from Hive directly |
| Geolocator stream dies | Recovery poller every 15s — checks GPS + permission, restarts stream |
| API sync fails (no internet) | Points stay in Hive, retry on next heartbeat |
| WatchdogReceiver restart | Read `shift_config` from Hive — no main app needed |
| Main app reopens mid-shift | `ClockInOutCubit` re-invokes `init` — background service refreshes config |
| `shift_config` not found on restart | Background service stops self — safer than tracking with no token |

---

## Verification

1. Clock in on OPPO F25 Pro → notification appears
2. Minimize app → lock screen → wait 5 minutes
3. Unlock → notification still visible, Hive has new points, server received data
4. Clock out → notification gone, Hive cleared
5. Kill app from recents → WatchdogReceiver restarts service → notification reappears, tracking resumes
6. Verify Vivo T3 Pro unaffected — same behavior
