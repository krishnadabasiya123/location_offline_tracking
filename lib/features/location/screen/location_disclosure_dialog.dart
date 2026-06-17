import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

/// Shows the Prominent Location Disclosure dialog required by Google Play Store.
/// Returns `true` if the user accepted, `false` if denied.
/// If [force] is true, shows the dialog even if already accepted.
Future<bool> showLocationDisclosure(BuildContext context, {bool force = false}) async {
  // Already accepted — skip unless forced
  if (!force && SettingLocalRepository.instance.isLocationDisclosureAccepted()) {
    return true;
  }

  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.location_on, size: 48.sp(context), color: ctx.colorScheme.primary),
        title: Text(
          'Location Access Disclosure',
          style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Omkar Sale collects location data to enable tracking of sales routes '
          'and customer visit verification even when the app is closed or '
          'not in use. This data is only collected while your shift is active '
          'and is used to provide accurate shift reports.\n\n'
          'Please select "Allow all the time" location access and enable Notifications to ensure tracking works.',
          style: ctx.textTheme.bodyMedium?.copyWith(
            color: ctx.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Deny', style: TextStyle(color: ctx.colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Accept & Continue'),
          ),
        ],
      );
    },
  );

  if (accepted ?? false) {
    await SettingLocalRepository.instance.setLocationDisclosureAccepted();
    return true;
  }

  return false;
}
