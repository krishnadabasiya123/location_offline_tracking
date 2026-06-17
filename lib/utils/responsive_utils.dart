import 'package:flutter/material.dart';

/// The core logic engine for responsive calculations.
class ResponsiveUtils {
  ResponsiveUtils._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 905;
  static const double desktopBreakpoint = 1240;
  static const double largeDesktopBreakpoint = 1440;

  // UI Multipliers
  static const double mobileMultiplier = 1;
  static const double tabletMultiplier = 1.2;
  static const double desktopMultiplier = 1.5;

  // Font Multipliers
  static const double mobileFontMultiplier = 1;
  static const double tabletFontMultiplier = 1.15;
  static const double desktopFontMultiplier = 1.35;

  /// Calculates responsive UI size (dp)
  static double getResponsiveSize(BuildContext context, double baseSize) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;

    return switch (shortestSide) {
      < mobileBreakpoint => baseSize * mobileMultiplier,
      < tabletBreakpoint => baseSize * tabletMultiplier,
      _ => baseSize * desktopMultiplier,
    };
  }

  /// Calculates responsive font size (sp)
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;

    return switch (shortestSide) {
      < mobileBreakpoint => baseFontSize * mobileFontMultiplier,
      < tabletBreakpoint => baseFontSize * tabletFontMultiplier,
      _ => baseFontSize * desktopFontMultiplier,
    };
  }

  /// Helper for returning different types of values based on screen size
  static T getResponsiveValue<T>(BuildContext context, {required T mobile, T? tablet, T? desktop}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint && desktop != null) return desktop;
    if (width >= mobileBreakpoint && tablet != null) return tablet;
    return mobile;
  }
}
