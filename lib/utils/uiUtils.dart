import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UiUtils {
  static const String appName = 'Omakar Sale';
  static int get locationUpdateInterval =>
      SettingLocalRepository.instance.getLocationUpdateInterval();

  static const String defaultLanguageCode = 'en';

  static const String defaultThemeKey = SettingLocalRepository.lightThemeKey;

  static Locale getLocaleFromLanguageCode(String languageCode) {
    final result = languageCode.split('-');
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static String twoCharacterString(String name) {
    // 1. Trim and split by any whitespace (handles multiple spaces)
    final names = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty) // Ensure no empty strings
        .toList();

    if (names.length >= 2) {
      // Check if the first and second words actually have characters
      final firstChar = names[0].isNotEmpty ? names[0][0] : '';
      final secondChar = names[1].isNotEmpty ? names[1][0] : '';
      return (firstChar + secondChar).toUpperCase();
    } else if (name.trim().length >= 2) {
      // If only one word, take first two letters of that word
      return name.trim().substring(0, 2).toUpperCase();
    }

    return name.trim().toUpperCase();
  }

  static Future<({String version, String buildCode})> getInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return (version: packageInfo.version, buildCode: packageInfo.buildNumber);
  }

  // --- NEW: Version Comparison Logic ---
  static Future<bool> shouldUpdate(String remoteVersionString) async {
    if (remoteVersionString.isEmpty) return false;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionString =
        '${packageInfo.version}+${packageInfo.buildNumber}';

    print(
      'Current App: $currentVersionString | Remote App: $remoteVersionString',
    );

    final currentBase = currentVersionString.split('+').first;
    final remoteBase = remoteVersionString.split('+').first;

    if (_isRemoteVersionHigher(currentBase, remoteBase)) return true;

    if (currentBase == remoteBase) {
      final currentBuild = _getBuildNumber(currentVersionString);
      final remoteBuild = _getBuildNumber(remoteVersionString);
      return remoteBuild > currentBuild;
    }

    return false;
  }

  static bool _isRemoteVersionHigher(String current, String remote) {
    final currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final remoteParts = remote
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    for (var i = 0; i < remoteParts.length; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (remoteParts[i] > currentPart) return true;
      if (remoteParts[i] < currentPart) return false;
    }
    return false;
  }

  static int _getBuildNumber(String versionString) {
    final parts = versionString.split('+');
    if (parts.length < 2) return 0;
    return int.tryParse(parts.last) ?? 0;
  }
}

class ForceUpdateDialog extends StatelessWidget {
  const ForceUpdateDialog({
    required this.version,
    required this.onUpdate,
    super.key,
  });
  final String version;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.rocket_fill,
                    size: 45,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Update Available!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'A new version is available with improved performance.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Version $version',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: onUpdate,
                  child: const Text(
                    'Update Now',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
