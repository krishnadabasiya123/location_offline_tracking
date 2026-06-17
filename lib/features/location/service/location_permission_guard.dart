import 'dart:io';

import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/cupertino.dart';
import 'package:omkar_sale/commons/repositories/setting_local_repositories.dart';
import 'package:omkar_sale/features/authentication/repositories/auth_local_repositories.dart';
import 'package:omkar_sale/features/location/screen/location_permission_screen.dart';
import 'package:omkar_sale/features/location/service/location_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized location/OEM permission + onboarding flow.
///
/// Runs the same sequence used by [LocationPermissionGuard] but as a static
/// async call you can `await` from anywhere that has a [BuildContext] — e.g.
/// from the Clock In button before starting the tracker.
///
/// Returns `true` once location-always is granted (the only hard requirement).
/// Activity recognition is soft. Battery opt + Oppo Auto-launch are fired
/// once.
class LocationOnboarding {
  LocationOnboarding._();

  static Future<bool> ensure(BuildContext context) async {
    // Notification — soft.
    final notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      await Permission.notification.request();
    }

    // Location "when in use"
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
    }
    if (!locationStatus.isGranted) {
      if (!context.mounted) return false;
      await Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => const LocationPermissionScreen(),
        ),
      );
      if (!context.mounted) return false;
      return ensure(context);
    }

    // Location "always"
    var alwaysStatus = await Permission.locationAlways.status;
    if (!alwaysStatus.isGranted) {
      alwaysStatus = await Permission.locationAlways.request();
    }
    if (!alwaysStatus.isGranted) {
      if (!context.mounted) return false;
      await Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => const LocationPermissionScreen(),
        ),
      );
      if (!context.mounted) return false;
      return ensure(context);
    }

    // Physical activity — soft, don't block.
    final activityStatus = await Permission.activityRecognition.status;
    if (activityStatus.isDenied) {
      await Permission.activityRecognition.request();
    }

    // Battery opt + Oppo Auto-launch
    if (Platform.isAndroid) {
      // Bg-isolate path (tracelet off): use disable_battery_optimization +
      // auto_start_flutter pkgs to prompt OEM dialogs.
      //
      // Auto-start — shown once per install. Deep-links to OEM autostart screen
      // (OPPO/VIVO/Xiaomi/Realme/OnePlus). Required for FGS survival after kill.
      if (!SettingLocalRepository.instance.isAutoStartDialogShown()) {
        try {
          final available = await isAutoStartAvailable ?? false;
          await SettingLocalRepository.instance.markAutoStartDialogShown();
          if (available) {
            await getAutoStartPermission();
          }
        } on Exception catch (_) {}
      }

      // Battery optimization — 3-state check:
      //   1. Standard Android battery opt
      //   2. OEM manufacturer opt
      //   3. Autostart whitelist (ColorOS kills FGS without it)
      try {
        final isStdDisabled =
            await DisableBatteryOptimization.isBatteryOptimizationDisabled ??
            true;
        final isOemDisabled =
            await DisableBatteryOptimization
                .isManufacturerBatteryOptimizationDisabled ??
            true;
        final isAutoStart =
            await DisableBatteryOptimization.isAutoStartEnabled ?? true;
        if (isStdDisabled && isOemDisabled && isAutoStart) {
          await SettingLocalRepository.instance.markBatteryOptDone();
        } else {
          final storedCount = SettingLocalRepository.instance
              .getBatteryOptDialogCount();
          final count = storedCount == 99 ? 0 : storedCount;
          if (storedCount == 99) {
            await SettingLocalRepository.instance.setBatteryOptDialogCount(0);
          }
          if (count < 10) {
            await DisableBatteryOptimization.showDisableAllOptimizationsSettings(
              'Enable Auto Start',
              'Allow this app to auto-start so location tracking works reliably in the background.',
              'Disable Battery Optimization',
              'Disable battery optimization for this app so it can track your location accurately on OPPO, VIVO, Xiaomi, and Samsung.',
            );
            final stdNow =
                await DisableBatteryOptimization
                    .isBatteryOptimizationDisabled ??
                true;
            final oemNow =
                await DisableBatteryOptimization
                    .isManufacturerBatteryOptimizationDisabled ??
                true;
            final autoNow =
                await DisableBatteryOptimization.isAutoStartEnabled ?? true;
            if (stdNow && oemNow && autoNow) {
              await SettingLocalRepository.instance.markBatteryOptDone();
            } else {
              await SettingLocalRepository.instance.setBatteryOptDialogCount(
                count + 1,
              );
            }
          }
        }
      } on Exception catch (_) {}
    }

    return true;
  }
}

/// Widget guard: runs [LocationOnboarding.ensure] only when the user has an
/// active shift (local or cross-device). For fresh users, renders the child
/// immediately — Clock In button handles its own prompts on tap.
class LocationPermissionGuard extends StatefulWidget {
  const LocationPermissionGuard({required this.child, super.key});

  final Widget child;

  @override
  State<LocationPermissionGuard> createState() =>
      _LocationPermissionGuardState();
}

class _LocationPermissionGuardState extends State<LocationPermissionGuard>
    with WidgetsBindingObserver {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeCheck());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ts = DateTime.now().toIso8601String();
    print('🔄 LIFECYCLE [$ts]: $state');

    if (state == AppLifecycleState.detached) {
      // OS is tearing down the activity. Often precedes process kill.
      print('⚠️ LIFECYCLE: detached — OS may kill process soon.');
    }

    if (state == AppLifecycleState.resumed) {
      // Kick the Dart event loop scheduler — OEM devices (OPPO/Xiaomi/OnePlus)
      // freeze the event loop while the screen is locked. This empty Future
      // unblocks queued microtasks and restores timer delivery on resume.
      Future<void>(() => null);

      _maybeCheck();

      LocationTracker.instance.onResume();
    }
  }

  Future<void> _maybeCheck() async {
    if (_isChecking || !mounted) return;
    if (!AuthLocalRepository.instance.getClockedInStatus()) return;
    _isChecking = true;
    try {
      await LocationOnboarding.ensure(context);
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
