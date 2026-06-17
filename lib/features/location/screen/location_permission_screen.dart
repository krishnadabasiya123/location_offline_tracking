import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> with WidgetsBindingObserver {
  bool _isChecking = false;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  /// Single pop path. Both the button and the lifecycle observer route through
  /// here, and the `_popped` flag guards against double-pop (which would pop
  /// MainScreen and leave a black screen).
  Future<void> _checkPermission() async {
    if (_isChecking || _popped) return;
    _isChecking = true;

    try {
      final granted = await Permission.locationAlways.isGranted;
      if (granted && mounted && !_popped) {
        _popped = true;
        Navigator.of(context).pop();
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.sp(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, size: 80.sp(context), color: context.colorScheme.primary),
                SizedBox(height: 24.sp(context)),
                Text(
                  'Location Permission Required',
                  style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp(context)),
                Text(
                  'This app requires "Allow all the time" location permission to track your shift accurately. Please enable it.',
                  style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.sp(context)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Step 1: "When in use"
                      var status = await Permission.location.status;
                      if (!status.isGranted) {
                        status = await Permission.location.request();
                      }

                      // Step 2: "Always" — only works after "When in use" is granted
                      if (status.isGranted) {
                        var alwaysStatus = await Permission.locationAlways.status;
                        if (!alwaysStatus.isGranted) {
                          alwaysStatus = await Permission.locationAlways.request();
                        }
                        if (alwaysStatus.isGranted) {
                          await _checkPermission();
                          return;
                        }
                      }

                      // Not granted — open settings; pop happens via the
                      // lifecycle observer when the user returns with the
                      // permission granted.
                      await openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16.sp(context))),
                    child: const Text('Allow Permission'),
                  ),
                ),
                SizedBox(height: 12.sp(context)),
                TextButton(
                  onPressed: openAppSettings,
                  child: Text('Manually open Settings', style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.5))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
