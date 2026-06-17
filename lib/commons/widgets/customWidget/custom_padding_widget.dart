import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class CustomPaddingWidget extends StatelessWidget {
  // Internal private constructor
  const CustomPaddingWidget._({
    required this.child,
    this.fixedLeftPadding,
    this.fixedRightPadding,
    this.fixedTopPadding,
    this.fixedBottomPadding,
    this.fixedHorizontalPadding,
    this.fixedVerticalPadding,
    this.fixedAllSidesPadding,
  });

  /// 1. Use this for specific sides (Left, Right, Top, Bottom).
  /// Default: Horizontal sides are 16.0, Vertical sides are 0.0.
  factory CustomPaddingWidget.only({required Widget child, double? fixedLeftPadding, double? fixedRightPadding, double? fixedTopPadding, double? fixedBottomPadding}) {
    return CustomPaddingWidget._(fixedLeftPadding: fixedLeftPadding, fixedRightPadding: fixedRightPadding, fixedTopPadding: fixedTopPadding, fixedBottomPadding: fixedBottomPadding, child: child);
  }

  /// 2. Use this for symmetric sides (Horizontal and Vertical).
  /// Default Horizontal: 16.0.
  /// Default Vertical: 0.0.
  factory CustomPaddingWidget.symmetric({required Widget child, double? fixedHorizontalPadding, double? fixedVerticalPadding}) {
    return CustomPaddingWidget._(fixedHorizontalPadding: fixedHorizontalPadding, fixedVerticalPadding: fixedVerticalPadding, child: child);
  }

  /// 3. Use this to apply the same padding to every side.
  /// Default: 16.0 on all sides.
  factory CustomPaddingWidget.all({required Widget child, double? fixedAllSidesPadding}) {
    return CustomPaddingWidget._(fixedAllSidesPadding: fixedAllSidesPadding, child: child);
  }
  final Widget child;

  // Variables for the .only constructor
  final double? fixedLeftPadding;
  final double? fixedRightPadding;
  final double? fixedTopPadding;
  final double? fixedBottomPadding;

  // Variables for the .symmetric constructor
  final double? fixedHorizontalPadding;
  final double? fixedVerticalPadding;

  // Variables for the .all constructor
  final double? fixedAllSidesPadding;

  @override
  Widget build(BuildContext context) {
    EdgeInsets finalPaddingResult;

    // Define your Project's default spacing here
    final defaultProjectHorizontalSpacing = 16.sp(context);
    const defaultProjectVerticalSpacing = 0;

    // IF USING .ALL
    if (fixedAllSidesPadding != null) {
      finalPaddingResult = EdgeInsets.all(fixedAllSidesPadding!);
    }
    // IF USING .SYMMETRIC
    else if (fixedHorizontalPadding != null || fixedVerticalPadding != null) {
      finalPaddingResult = EdgeInsets.symmetric(
        horizontal: fixedHorizontalPadding ?? defaultProjectHorizontalSpacing,
        vertical: fixedVerticalPadding ?? defaultProjectVerticalSpacing.toDouble(),
      );
    }
    // IF USING .ONLY (OR DEFAULT)
    else {
      finalPaddingResult = EdgeInsets.only(
        left: fixedLeftPadding ?? defaultProjectHorizontalSpacing,
        right: fixedRightPadding ?? defaultProjectHorizontalSpacing,
        top: fixedTopPadding ?? defaultProjectVerticalSpacing.toDouble(),
        bottom: fixedBottomPadding ?? defaultProjectVerticalSpacing.toDouble(),
      );
    }

    return Padding(padding: finalPaddingResult, child: child);
  }
}

// import 'package:flutter/material.dart';
// // Adjust this import to match your actual extension file path
// import 'package:omkar_sale/utils/extensions/context_size_extensions.dart';

// class ResponsiveAppPadding extends StatelessWidget {
//   final Widget child;

//   // Variables for .only constructor
//   final double? fixedLeftPadding;
//   final double? screenWidthLeftFactor;
//   final double? fixedRightPadding;
//   final double? screenWidthRightFactor;
//   final double? fixedTopPadding;
//   final double? screenHeightTopFactor;
//   final double? fixedBottomPadding;
//   final double? screenHeightBottomFactor;

//   // Variables for .symmetric constructor
//   final double? fixedHorizontalPadding;
//   final double? screenWidthHorizontalFactor;
//   final double? fixedVerticalPadding;
//   final double? screenHeightVerticalFactor;

//   // Variables for .all constructor
//   final double? fixedAllSidesPadding;
//   final double? screenWidthAllSidesFactor;

//   // Private constructor to store the values
//   const ResponsiveAppPadding._({
//     required this.child,
//     this.fixedLeftPadding,
//     this.screenWidthLeftFactor,
//     this.fixedRightPadding,
//     this.screenWidthRightFactor,
//     this.fixedTopPadding,
//     this.screenHeightTopFactor,
//     this.fixedBottomPadding,
//     this.screenHeightBottomFactor,
//     this.fixedHorizontalPadding,
//     this.screenWidthHorizontalFactor,
//     this.fixedVerticalPadding,
//     this.screenHeightVerticalFactor,
//     this.fixedAllSidesPadding,
//     this.screenWidthAllSidesFactor,
//   });

//   /// 1. Create padding for specific sides.
//   /// If no horizontal values are provided, it defaults to 3.5% of screen width.
//   factory ResponsiveAppPadding.only({
//     required Widget child,
//     double? fixedLeftPadding,
//     double? screenWidthLeftFactor,
//     double? fixedRightPadding,
//     double? screenWidthRightFactor,
//     double? fixedTopPadding,
//     double? screenHeightTopFactor,
//     double? fixedBottomPadding,
//     double? screenHeightBottomFactor,
//   }) {
//     return ResponsiveAppPadding._(
//       fixedLeftPadding: fixedLeftPadding,
//       screenWidthLeftFactor: screenWidthLeftFactor,
//       fixedRightPadding: fixedRightPadding,
//       screenWidthRightFactor: screenWidthRightFactor,
//       fixedTopPadding: fixedTopPadding,
//       screenHeightTopFactor: screenHeightTopFactor,
//       fixedBottomPadding: fixedBottomPadding,
//       screenHeightBottomFactor: screenHeightBottomFactor,
//       child: child,
//     );
//   }

//   /// 2. Create symmetric padding (Horizontal and Vertical).
//   /// Default Horizontal: 3.5% of screen width.
//   /// Default Vertical: 0.0.
//   factory ResponsiveAppPadding.symmetric({
//     required Widget child,
//     double? fixedHorizontalPadding,
//     double? screenWidthHorizontalFactor,
//     double? fixedVerticalPadding,
//     double? screenHeightVerticalFactor,
//   }) {
//     return ResponsiveAppPadding._(
//       fixedHorizontalPadding: fixedHorizontalPadding,
//       screenWidthHorizontalFactor: screenWidthHorizontalFactor,
//       fixedVerticalPadding: fixedVerticalPadding,
//       screenHeightVerticalFactor: screenHeightVerticalFactor,
//       child: child,
//     );
//   }

//   /// 3. Create equal padding for all sides.
//   /// Default: 3.5% of screen width.
//   factory ResponsiveAppPadding.all({required Widget child, double? fixedAllSidesPadding, double? screenWidthAllSidesFactor}) {
//     return ResponsiveAppPadding._(fixedAllSidesPadding: fixedAllSidesPadding, screenWidthAllSidesFactor: screenWidthAllSidesFactor, child: child);
//   }

//   @override
//   Widget build(BuildContext context) {
//     EdgeInsets finalComputedPadding;

//     // Default configuration
//     const double defaultHorizontalFactor = 0.035; // 3.5%
//     const double defaultVerticalFactor = 0.0; // 0%

//     // LOGIC FOR .ALL
//     if (fixedAllSidesPadding != null || screenWidthAllSidesFactor != null) {
//       final double value = fixedAllSidesPadding ?? (context.screenWidth * (screenWidthAllSidesFactor ?? defaultHorizontalFactor));
//       finalComputedPadding = EdgeInsets.all(value);
//     }
//     // LOGIC FOR .SYMMETRIC
//     else if (fixedHorizontalPadding != null || screenWidthHorizontalFactor != null || fixedVerticalPadding != null || screenHeightVerticalFactor != null) {
//       final double horizontal = fixedHorizontalPadding ?? (context.screenWidth * (screenWidthHorizontalFactor ?? defaultHorizontalFactor));

//       final double vertical = fixedVerticalPadding ?? (context.screenHeight * (screenHeightVerticalFactor ?? defaultVerticalFactor));

//       finalComputedPadding = EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
//     }
//     // LOGIC FOR .ONLY
//     else {
//       final double left = fixedLeftPadding ?? (context.screenWidth * (screenWidthLeftFactor ?? defaultHorizontalFactor));

//       final double right = fixedRightPadding ?? (context.screenWidth * (screenWidthRightFactor ?? defaultHorizontalFactor));

//       final double top = fixedTopPadding ?? (context.screenHeight * (screenHeightTopFactor ?? defaultVerticalFactor));

//       final double bottom = fixedBottomPadding ?? (context.screenHeight * (screenHeightBottomFactor ?? defaultVerticalFactor));

//       finalComputedPadding = EdgeInsets.only(left: left, right: right, top: top, bottom: bottom);
//     }

//     return Padding(padding: finalComputedPadding, child: child);
//   }
// }
