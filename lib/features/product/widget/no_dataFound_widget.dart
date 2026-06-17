import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

enum CustomErrorType {
  noInternet(AppImage.noInternet, 'noInternetTitleLbl', 'noInternetMsgLbl'),
  noDataFound(AppImage.noDataFound, 'noDataFoundTitleLbl', 'noDataFoundMsgLbl'),
  generalError(AppImage.generalError, 'somethingWentWrongLbl', 'pleaseTryAgainLater'),
  noImageError(null, 'errorTitle', 'errorMsg');

  final String? imagePath;
  final String titleKey;
  final String subtitleKey;

  const CustomErrorType(this.imagePath, this.titleKey, this.subtitleKey);
}

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({
    super.key,
    this.errorType, // Added this
    /// Image
    this.imagePath,
    this.imageWidget,
    this.imageHeight,
    this.imageWidth,
    this.imageFit = BoxFit.contain,

    /// Text
    this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,

    /// Retry Button
    this.onRetry,
    this.retryButtonText,
    this.retryButtonColor,
    this.retryButtonTextStyle,
    this.retryButtonRadius,
    this.showRetryButton = true,
    this.retryButtonWidth,
    this.retryButtonHeight,

    /// Layout
    this.spacing = 16,
    this.padding,
    this.alignment = Alignment.center,
  });

  final CustomErrorType? errorType; // New parameter

  /// Image support
  final String? imagePath;
  final Widget? imageWidget;
  final double? imageHeight;
  final double? imageWidth;
  final BoxFit imageFit;

  /// Text
  final String? title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  /// Retry
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final Color? retryButtonColor;
  final TextStyle? retryButtonTextStyle;
  final BorderRadius? retryButtonRadius;
  final bool showRetryButton;
  final double? retryButtonWidth;
  final double? retryButtonHeight;

  /// Layout
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- LOGIC: Resolve which data to show ---
    // 1. Resolve Image Path
    final effectiveImagePath = imagePath ?? errorType?.imagePath;

    // 2. Resolve Title (Manual title OR translated Enum title)
    final effectiveTitle = title ?? errorType?.titleKey.tr(context);

    // 3. Resolve Subtitle (Manual subtitle OR translated Enum subtitle)
    final effectiveSubtitle = subtitle ?? errorType?.subtitleKey.tr(context);
    // ------------------------------------------

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Priority: imageWidget > manual imagePath > enum imagePath
              if (imageWidget != null)
                imageWidget!
              else if (effectiveImagePath != null)
                Container(
                  decoration: BoxDecoration(color: context.isDarkMode ? const Color.fromARGB(249, 255, 255, 255) : null, borderRadius: BorderRadius.circular(15.sp(context))),
                  padding: EdgeInsets.symmetric(horizontal: 10.sp(context)),
                  child: CustomImageWidget(imagePath: effectiveImagePath, height: imageHeight ?? 200.sp(context), width: imageWidth ?? 200.sp(context), fit: imageFit),
                ),

              if (imageWidget != null || effectiveImagePath != null) SizedBox(height: spacing),

              /// Title
              if (effectiveTitle != null)
                Text(
                  effectiveTitle,
                  textAlign: TextAlign.center,
                  style: titleStyle ?? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),

              if (effectiveTitle != null && effectiveSubtitle != null) const SizedBox(height: 6),

              /// Subtitle
              if (effectiveSubtitle != null)
                Text(
                  effectiveSubtitle,
                  textAlign: TextAlign.center,
                  style: subtitleStyle ?? theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),

              /// Retry Button
              if (showRetryButton && onRetry != null) ...[
                SizedBox(height: spacing + 4),
                CustomRoundedButtonWidget(
                  width: retryButtonWidth ?? 200.sp(context),
                  onPressed: onRetry,
                  height: retryButtonHeight ?? 48.sp(context),
                  text: retryButtonText ?? 'retryLbl'.tr(context),
                  backgroundColor: retryButtonColor ?? theme.colorScheme.primary,
                  textStyle: retryButtonTextStyle ?? theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                  borderRadius: retryButtonRadius ?? BorderRadius.circular(12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_image_widget.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_rounded_button_widget.dart';
// import 'package:omkar_sale/core/constants/app_image.dart';
// import 'package:omkar_sale/utils/extensions/num_extensions.dart';
// import 'package:omkar_sale/utils/extensions/string_extensopns.dart';
// import 'package:omkar_sale/utils/extensions/theme_extensions.dart';

// enum CustomErrorType {
//   noInternet(AppImage.homeActive),
//   noDataFound(AppImage.homeActive),
//   generalError(AppImage.homeActive),
//   noImageError(null)
//   ;

//   final String? imagePath;

//   const CustomErrorType(this.imagePath);
// }

// // class NoDataFoundWidget extends StatelessWidget {
// //   const NoDataFoundWidget({
// //     required this.onRefresh,
// //     super.key,
// //     this.title = 'productCatalogIsEmptyLbl',
// //     this.description = "We couldn't find any products in your catalog. Try refreshing or check your connection.",
// //   });
// //   final VoidCallback onRefresh;
// //   final String title;
// //   final String description;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: SingleChildScrollView(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             // Icon Section with Rotated Containers
// //             Stack(
// //               clipBehavior: Clip.none,
// //               children: [
// //                 // Soft blur background effect

// //                 // Main Tilting Container
// //                 Transform.rotate(
// //                   angle: 6 * pi / 180,
// //                   child: Container(
// //                     height: 110.sp(context),
// //                     width: 110.sp(context),
// //                     decoration: BoxDecoration(
// //                       color: context.colorScheme.secondary,
// //                       borderRadius: BorderRadius.circular(40.sp(context)),
// //                       boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 40, offset: const Offset(0, 8))],
// //                       border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
// //                     ),
// //                     child: Icon(Icons.inventory_2, size: 50.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.2)),
// //                   ),
// //                 ),
// //                 // Overlapping Search Off Icon
// //                 Positioned(
// //                   top: -10,
// //                   right: -15,
// //                   child: Transform.rotate(
// //                     angle: -12 * pi / 180,
// //                     child: Container(
// //                       height: 40.sp(context),
// //                       width: 40.sp(context),
// //                       decoration: BoxDecoration(
// //                         color: context.colorScheme.secondary,
// //                         borderRadius: BorderRadius.circular(16.sp(context)),
// //                         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
// //                         border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.1)),
// //                       ),
// //                       child: Icon(Icons.search_off, size: 20.sp(context), color: context.colorScheme.primary),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 30.sp(context)),
// //             // Text Section
// //             Text(
// //               title,
// //               style: TextStyle(fontSize: 19.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.onSurface),
// //               textAlign: TextAlign.center,
// //             ),
// //             SizedBox(height: 12.sp(context)),
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 30.sp(context)),
// //               child: Text(
// //                 description,
// //                 style: TextStyle(fontSize: 14.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ),
// //             SizedBox(height: 30.sp(context)),
// //             // Refresh Button
// //             SizedBox(
// //               width: 200.sp(context),
// //               height: 40.sp(context),
// //               child: ElevatedButton.icon(
// //                 onPressed: onRefresh,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: context.colorScheme.primary,
// //                   foregroundColor: Colors.white,
// //                   elevation: 5,
// //                   shadowColor: context.colorScheme.primary.withValues(alpha: 0.3),
// //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.sp(context))),
// //                 ),
// //                 icon: Icon(Icons.refresh, size: 16.sp(context)),
// //                 label: Text(
// //                   'Refresh',
// //                   style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// class CustomErrorWidget extends StatelessWidget {
//   const CustomErrorWidget({
//     super.key,

//     /// Image
//     this.imagePath,
//     this.imageWidget,
//     this.imageHeight,
//     this.imageWidth,
//     this.imageFit = BoxFit.contain,

//     /// Text
//     this.title,
//     this.subtitle,
//     this.titleStyle,
//     this.subtitleStyle,

//     /// Retry Button
//     this.onRetry,
//     this.retryButtonText,
//     this.retryButtonColor,
//     this.retryButtonTextStyle,
//     this.retryButtonRadius,
//     this.showRetryButton = true,
//     this.retryButtonWidth,

//     /// Layout
//     this.spacing = 16,
//     this.padding,
//     this.alignment = Alignment.center,
//   });

//   /// Image support
//   final String? imagePath; // Asset / Network
//   final Widget? imageWidget; // Lottie / SVG / Custom
//   final double? imageHeight;
//   final double? imageWidth;
//   final BoxFit imageFit;

//   /// Text
//   final String? title;
//   final String? subtitle;
//   final TextStyle? titleStyle;
//   final TextStyle? subtitleStyle;

//   /// Retry
//   final VoidCallback? onRetry;
//   final String? retryButtonText;
//   final Color? retryButtonColor;
//   final TextStyle? retryButtonTextStyle;
//   final BorderRadius? retryButtonRadius;
//   final bool showRetryButton;
//   final double? retryButtonWidth;

//   /// Layout
//   final double spacing;
//   final EdgeInsetsGeometry? padding;
//   final Alignment alignment;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Align(
//       alignment: alignment,
//       child: Padding(
//         padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             /// Priority: imageWidget > imagePath
//             if (imageWidget != null)
//               imageWidget!
//             else if (imagePath != null)
//               CustomImageWidget(imagePath: imagePath!, height: imageHeight ?? 200.sp(context), width: imageWidth ?? 200.sp(context), fit: imageFit),

//             //Image(image: _resolveImage(imagePath!), height: imageHeight ?? 200, width: imageWidth ?? 200, fit: imageFit),
//             if (imageWidget != null || imagePath != null) SizedBox(height: spacing),

//             /// Title
//             if (title != null)
//               Text(
//                 title!,
//                 textAlign: TextAlign.center,
//                 style: titleStyle ?? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//               ),

//             if (title != null && subtitle != null) const SizedBox(height: 6),

//             /// Subtitle
//             if (subtitle != null)
//               Text(
//                 subtitle!,
//                 textAlign: TextAlign.center,
//                 style: subtitleStyle ?? theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha:0.7)),
//               ),

//             /// Retry Button
//             if (showRetryButton && onRetry != null) ...[
//               SizedBox(height: spacing + 4),

//               CustomRoundedButtonWidget(
//                 width: retryButtonWidth ?? 200.sp(context),
//                 onPressed: onRetry,
//                 text: retryButtonText ?? 'retryLbl'.tr(context),
//                 backgroundColor: retryButtonColor ?? theme.colorScheme.primary,
//                 textStyle: retryButtonTextStyle ?? theme.textTheme.labelLarge?.copyWith(color: Colors.white),
//                 borderRadius: retryButtonRadius ?? BorderRadius.circular(12),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
