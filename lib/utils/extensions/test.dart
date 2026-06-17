import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omkar_sale/core/theme/color.dart'; // Adjust path to your colors file

extension AppOverlayStyle on BuildContext {
  /// Use this for standard screens (Login, Home, etc.)
  /// where the status bar should match the background.
  SystemUiOverlayStyle get surfaceSystemOverlay {
    final isDark = Theme.of(this).brightness == Brightness.dark;

    return SystemUiOverlayStyle(
      // Status Bar
      statusBarColor: isDark ? AppThemeColors.darkSurfaceColor : AppThemeColors.lightSurfaceColor,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Inverted icons
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // For iOS
      // Navigation Bar (Bottom)
      systemNavigationBarColor: isDark ? AppThemeColors.darkSurfaceColor : AppThemeColors.lightSurfaceColor,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }

  /// Use this for screens that have a solid primary color header
  /// (like a blue Splash screen or a blue header).
  SystemUiOverlayStyle get primarySystemOverlay {
    final isDark = Theme.of(this).brightness == Brightness.dark;

    return SystemUiOverlayStyle(
      // Status Bar (Blue)
      statusBarColor: isDark ? AppThemeColors.darkPrimaryColor : AppThemeColors.lightPrimaryColor,
      statusBarIconBrightness: Brightness.light, // Always white icons on blue
      statusBarBrightness: Brightness.dark,

      // Navigation Bar
      systemNavigationBarColor: isDark ? AppThemeColors.darkSurfaceColor : AppThemeColors.lightPrimaryColor,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }
}
