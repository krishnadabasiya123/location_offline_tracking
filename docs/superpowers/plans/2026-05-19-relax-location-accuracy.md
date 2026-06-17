# Relax Location Accuracy Threshold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Relax the location accuracy threshold from 35m to 100m to improve background tracking reliability on Android devices.

**Architecture:** Update the hardcoded accuracy gates in the `LocationTracker` singleton and synchronize the heartbeat fallback logic to match.

**Tech Stack:** Flutter, Geolocator, Dart.

---

### Task 1: Update Accuracy Gates in LocationTracker

**Files:**
- Modify: `lib/features/location/service/lib/features/location/service/location_service.dart`

- [ ] **Step 1: Update _processLocation accuracy check**

Find and replace the 35m check in `_processLocation` with 100m.

```dart
// lib/features/location/service/lib/features/location/service/location_service.dart

// OLD
if (position.accuracy > 35) {
  if (kDebugMode) {
    print(
      '❌ REJECTED (accuracy) '
      '${position.accuracy.toStringAsFixed(1)}m > 35m',
    );
  }
  return;
}

// NEW
if (position.accuracy > 100) {
  if (kDebugMode) {
    print(
      '❌ REJECTED (accuracy) '
      '${position.accuracy.toStringAsFixed(1)}m > 100m',
    );
  }
  return;
}
```

- [ ] **Step 2: Update _checkSyncDue heartbeat accuracy check**

Find and replace the 35m check in `_checkSyncDue` with 100m.

```dart
// lib/features/location/service/lib/features/location/service/location_service.dart

// OLD
if (position.accuracy <= 35) {
  await _processLocation(position);
} else if (kDebugMode) {
  print(
    '⚠️ HEARTBEAT: Inaccurate fix '
    '(${position.accuracy.toStringAsFixed(1)}m) — skipping.',
  );
}

// NEW
if (position.accuracy <= 100) {
  await _processLocation(position);
} else if (kDebugMode) {
  print(
    '⚠️ HEARTBEAT: Inaccurate fix '
    '(${position.accuracy.toStringAsFixed(1)}m) — skipping.',
  );
}
```

- [ ] **Step 3: Update comments and documentation**

Update the "GATE 1" comment and any other descriptive text in the file that mentions the 35m standard.

```dart
// lib/features/location/service/lib/features/location/service/location_service.dart

// OLD
// ── GATE 1: ACCURACY — Universal 35m Standard ───────────────────────────
// Satellite fix   →  5m – 35m   ✅ accepted
// Cell tower guess → 50m – 5000m ❌ rejected

// NEW
// ── GATE 1: ACCURACY — Relaxed 100m Standard ───────────────────────────
// Satellite fix   →  5m – 100m   ✅ accepted
// Cell tower guess → 150m – 5000m ❌ rejected
```

- [ ] **Step 4: Commit changes**

```bash
git add lib/features/location/service/lib/features/location/service/location_service.dart
git commit -m "feat(location): relax accuracy threshold from 35m to 100m for better tracking reliability"
```

---

### Task 2: Verification (Manual & Log Review)

**Files:**
- Review: `lib/features/location/service/lib/features/location/service/location_service.dart`

- [ ] **Step 1: Verify all active instances of 35m are updated**

Run a grep to ensure no active (non-commented) 35m accuracy checks remain in the file.

Run: `grep "accuracy.*35" lib/features/location/service/lib/features/location/service/location_service.dart`
Expected: Only commented-out lines (starting with `//`) should appear.

- [ ] **Step 2: Verify code compiles**

Run: `flutter pub get` (to ensure environment is clean)
Run: `flutter analyze` (or check IDE for errors)
Expected: No errors in `location_service.dart`.
