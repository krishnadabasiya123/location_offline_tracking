import 'package:flutter/material.dart';
import 'package:omkar_sale/utils/responsive_utils.dart';

/// Basic screen dimension shortcuts
extension ContextDimensionExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}

/// Complex responsive layout scaling
extension ContextLayoutExtension on BuildContext {
  /// Fraction of screen width with responsive scaling
  double dpWidth(double fraction) {
    return ResponsiveUtils.getResponsiveSize(this, screenWidth * fraction);
  }

  /// Fraction of screen height with responsive scaling
  double dpHeight(double fraction) {
    return ResponsiveUtils.getResponsiveSize(this, screenHeight * fraction);
  }

  /// Responsive font size via context: usage -> context.spFont(18)
  double spFont(double fontSize) {
    return ResponsiveUtils.getResponsiveFontSize(this, fontSize);
  }
}

// **************** example **************
// 1. Using .dp and .sp for responsive sizes and fonts
/*
Column(
  children: [
    Container(
      width: 200.dp(context),  // Scales based on device screen size
      height: 100.dp(context),
      color: context.primaryColor,
    ),
    CustomTextWidget(
      "Responsive Font",
      fontSize: 18.sp(context), // Font scales perfectly on small/large phones
    ),
  ],
)
*/

// 2. Using screen fractions and dimension shortcuts
/*
Container(
  width: context.seventyPercentWidth, // 70% of screen width
  height: context.halfScreenHeight,   // 50% of screen height
  padding: context.padding,           // Uses MediaQuery padding (safe area)
  child: CustomTextWidget("Screen width is: ${context.screenWidth}"),
)
*/
