  import 'package:flutter/material.dart';
import 'package:omkar_sale/utils/responsive_utils.dart';

/// Extensions on [BuildContext] for responsive layout and scaling.
extension BuildContextExt on BuildContext {
  // --- Basic Dimensions ---
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
  double get shortestSide => MediaQuery.sizeOf(this).shortestSide;
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  // --- Breakpoint Checks ---
  // We use the granular getters to define the main categories to avoid repeating math
  bool get isMobile => shortestSide < ResponsiveUtils.mobileBreakpoint;
  bool get isTablet => shortestSide >= ResponsiveUtils.mobileBreakpoint && shortestSide < ResponsiveUtils.tabletBreakpoint;
  bool get isDesktop => shortestSide >= ResponsiveUtils.tabletBreakpoint;

  // // Granular Breakpoints
  // bool get isXSmall => shortestSide < ResponsiveUtils.mobileBreakpoint;
  // bool get isSmall => shortestSide < ResponsiveUtils.tabletBreakpoint;
  // bool get isMedium => shortestSide < ResponsiveUtils.desktopBreakpoint;
  // bool get isLarge => shortestSide < ResponsiveUtils.largeDesktopBreakpoint;

  bool get isRTL => Directionality.of(this) == TextDirection.rtl;

  // --- Scaling Logic (The only place calling ResponsiveUtils) ---
  double dp(double size) => ResponsiveUtils.getResponsiveSize(this, size);
  double sp(double size) => ResponsiveUtils.getResponsiveFontSize(this, size);
}

/// Extensions on [num] - Redirects to BuildContextExt to avoid duplication
extension NumScalingExtension on num {
  /// usage: 16.sp(context)
  double sp(BuildContext context) => context.sp(toDouble());

  /// usage: 100.dp(context)
  double dp(BuildContext context) => context.dp(toDouble());
}
