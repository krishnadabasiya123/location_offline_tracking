import 'package:package_info_plus/package_info_plus.dart';

extension PackageInfoExtension on PackageInfo {
  // Method 1: Get Version (v1.0.2)
  String get appVersion => 'v$version';

  // Method 2: Get Build Number (Build 8920)
  String get buildNumberLabel => 'Build $buildNumber';

  // Bonus: Get combined string
  String get fullVersion => '$appVersion • $buildNumberLabel';
}
