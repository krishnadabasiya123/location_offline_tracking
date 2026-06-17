import 'package:flutter/material.dart';

/// Access Theme and ColorScheme values directly from context
extension ThemeExtensions on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  Color get primaryColor => Theme.of(this).primaryColor;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;

  //i want check current theme

  Color get primaryTextColor => Theme.of(this).colorScheme.onTertiary;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Returns true if the current theme is Light
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get titleSmall => textTheme.titleSmall;

  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get headlineSmall => textTheme.headlineSmall;

  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodySmall => textTheme.bodySmall;

  TextStyle? get labelLarge => textTheme.labelLarge;
  TextStyle? get labelMedium => textTheme.labelMedium;
  TextStyle? get labelSmall => textTheme.labelSmall;
}
