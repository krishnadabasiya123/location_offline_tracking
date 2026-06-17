# Design Spec: Relaxing Location Accuracy Threshold

**Date:** 2026-05-19
**Topic:** location-accuracy-fix
**Status:** Approved

## 1. Problem Statement
The user observed only 18 location points for a 7 km, 18-minute journey on an Android physical device. This suggests a rate of 1 point per minute, which matches the `LocationTracker`'s heartbeat timer interval (60 seconds). This implies that the background location stream is either not firing or is being rejected by current filters, leaving only the heartbeat as a fallback.

The primary suspect is the **Accuracy Gate**, which currently rejects any point with accuracy > 35m. On many Android devices, especially when using `forceLocationManager: true` (pure GPS), achieving consistent < 35m accuracy while moving or in semi-obstructed areas can be difficult, leading to a high rejection rate.

## 2. Proposed Solution
Relax the accuracy threshold from **35m to 100m**.

### 2.1 Rationale
- **100m** is still sufficient to distinguish between a valid GPS fix and a generic cell-tower estimate (which typically has accuracy of 500m to 5000m).
- Many mid-range Android devices report accuracy between 40m and 80m when they have a satellite lock but not an ideal configuration (e.g., fewer satellites or poor signal-to-noise ratio).
- This will allow the background stream to pass points more frequently, providing a more detailed travel history (aiming for the 5-second interval defined in `locationSettings`).

## 3. Implementation Plan
1.  Modify `lib/features/location/service/lib/features/location/service/location_service.dart`.
2.  Update the check in `_processLocation` from `position.accuracy > 35` to `position.accuracy > 100`.
3.  Update the check in `_checkSyncDue` (heartbeat) from `position.accuracy <= 35` to `position.accuracy <= 100`.
4.  Update relevant log messages and comments to reflect the new 100m standard.

## 4. Risks & Mitigations
- **Risk:** Increased "jitter" or "teleporting" if low-accuracy points are accepted.
- **Mitigation:** The existing **Jitter Gate** (`distance < 3m`) and **Speed Gate** (`speed > 70m/s`) will still filter out small noise and impossible jumps.

## 5. Approval
Approved by user via brainstorming session.
