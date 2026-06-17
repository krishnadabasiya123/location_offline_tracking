import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

extension CustomDialogExtension on BuildContext {
  /// Quick helper for Error Dialogs
  // Future<void> showCustomErrorDialog(String message) {
  //   return showCustomDialog(
  //     title: 'errorTitle'.tr(this),
  //     message: message,
  //     confirmButtonText: 'closeBtnLbl'.tr(this),
  //     icon: Icon(
  //       Icons.error_outline_rounded,
  //       color: AppThemeColors.redColor,
  //       size: 32.sp(this),
  //     ),
  //   );
  // }

  /// The highly customizable animated dialog
  Future<T?> showCustomDialog<T>({
    String? title,
    String? message,
    String? image,
    Widget? icon,
    String? confirmButtonText,
    String? cancelButtonText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDismissible = true,
    bool isLoading = false,
    String? loadingText,
    void Function(bool, T?)? onPopInvokedWithResult,
  }) {
    // If a pop callback is provided, we must set canPop to false for it to trigger.
    // Otherwise, it follows the isDismissible flag.
    final effectiveCanPop = !(onPopInvokedWithResult != null) && isDismissible;

    return showGeneralDialog<T>(
      context: this,
      barrierDismissible: isDismissible,
      barrierLabel: 'CustomDialog',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogCtx, anim1, anim2) => CustomDialogWidget<T>(
        title: title,
        message: message,
        image: image,
        icon: icon,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        isLoading: isLoading,
        loadingText: loadingText,
        canPop: effectiveCanPop,
        onPopInvokedWithResult: onPopInvokedWithResult,
        onConfirm: () {
          Navigator.of(dialogCtx).pop();
          onConfirm?.call();
        },
        onCancel: onCancel ?? () => Navigator.of(dialogCtx).pop(),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Advanced Scale + Fade + Blur Animation
        return Transform.scale(
          scale: Curves.easeOutBack.transform(animation.value),
          child: Opacity(
            opacity: animation.value,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8 * animation.value,
                sigmaY: 8 * animation.value,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class CustomDialogWidget<T> extends StatelessWidget {
  const CustomDialogWidget({
    super.key,
    this.image,
    this.icon,
    this.title,
    this.message,
    this.confirmButtonText,
    this.onConfirm,
    this.cancelButtonText,
    this.onCancel,
    this.isLoading = false,
    this.loadingText,
    this.canPop = true,
    this.onPopInvokedWithResult,
  });

  final String? image;
  final Widget? icon;
  final String? title;
  final String? message;
  final String? confirmButtonText;
  final VoidCallback? onConfirm;
  final String? cancelButtonText;
  final VoidCallback? onCancel;
  final bool isLoading;
  final String? loadingText;
  final bool canPop;
  final void Function(bool, T?)? onPopInvokedWithResult;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Responsive horizontal margin
      insetPadding: EdgeInsets.symmetric(horizontal: 32.sp(context)),
      backgroundColor: context.colorScheme.secondary, // Uses Slate/Navy background
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.sp(context)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: PopScope<T>(
        canPop: canPop,
        onPopInvokedWithResult: onPopInvokedWithResult,
        child: Padding(
          padding: EdgeInsets.all(24.sp(context)),
          child: isLoading ? _buildLoadingContent(context) : _buildNormalContent(context),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomCircularProgressIndicator(),
        if (loadingText != null) ...[
          SizedBox(height: 20.sp(context)),
          CustomTextWidget(
            loadingText!,
            textAlign: TextAlign.center,
            fontSize: 16.sp(context),
            fontWeight: FontWeight.w600,
            color: context.colorScheme.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildNormalContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. --- TOP VISUAL (Image or Icon) ---
        if (image != null) ...[
          CustomImageWidget(
            imagePath: image!,
            height: 120.sp(context),
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.sp(context)),
        ] else if (icon != null) ...[
          _buildGlowIcon(context),
          SizedBox(height: 20.sp(context)),
        ],

        // 2. --- TITLE ---
        if (title != null) ...[
          CustomTextWidget(
            title!,
            textAlign: TextAlign.center,
            fontSize: 22.sp(context),
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSecondary,
            height: 1.2,
          ),
          SizedBox(height: 12.sp(context)),
        ],

        // 3. --- MESSAGE ---
        if (message != null) ...[
          CustomTextWidget(
            message!,
            textAlign: TextAlign.center,
            fontSize: 15.sp(context),
            color: AppThemeColors.darkGreyColor, // slate-400
            height: 1.4,
            maxLines: 5,
          ),
          SizedBox(height: 32.sp(context)),
        ],

        // 4. --- ACTIONS (Buttons) ---
        if (cancelButtonText != null || confirmButtonText != null)
          Row(
            children: [
              if (cancelButtonText != null)
                Expanded(
                  child: CustomRoundedButtonWidget(
                    onPressed: onCancel,
                    text: cancelButtonText,
                    height: 48.sp(context),
                    backgroundColor: Colors.transparent,
                    foregroundColor: context.colorScheme.onSecondary,
                    borderSide: BorderSide(
                      color: context.colorScheme.onSecondary.withValues(alpha: 0.1),
                    ),
                    textStyle: TextStyle(
                      fontSize: 14.sp(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (cancelButtonText != null && confirmButtonText != null) SizedBox(width: 12.sp(context)),
              if (confirmButtonText != null)
                Expanded(
                  child: CustomRoundedButtonWidget(
                    onPressed: onConfirm,
                    text: confirmButtonText,
                    height: 48.sp(context),
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: context.colorScheme.primary,
                    textStyle: TextStyle(
                      fontSize: 14.sp(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// Builds a circular glowing container for the icon
  Widget _buildGlowIcon(BuildContext context) {
    // Determine color based on title/icon type (Defaults to primary)
    final iconColor = (icon is Icon) ? (icon! as Icon).color ?? context.colorScheme.primary : context.colorScheme.primary;

    return Container(
      height: 64.sp(context),
      width: 64.sp(context),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 20.sp(context),
            spreadRadius: 2.sp(context),
          ),
        ],
      ),
      child: icon,
    );
  }
}
// **************** example **************
// 1. Show a simple Error Dialog
/*
context.showCustomErrorDialog("Something went wrong, please try again later.");
*/

// 2. Show a Confirmation Dialog with Image and Two Buttons
/*
context.showCustomDialog(
  title: "Delete Item?",
  message: "Are you sure you want to remove this item from your cart?",
  image: "assets/images/delete_warning.svg",
  confirmButtonText: "Yes, Delete",
  cancelButtonText: "Keep it",
  onConfirm: () {
    // Logic to delete
    print("Item deleted");
  },
);
*/

// 3. Show a Loading Dialog with Custom Text
/*
context.showCustomDialog(
  isLoading: true,
  loadingText: "Processing Payment...",
  barrierDismissible: false, // User cannot click outside to close
);
*/
  // 4. Show a simple Error Dialog  
  /*
  context.showCustomErrorDialog("Something went wrong, please try again later.");
  */
  
  // 5. Show a Confirmation Dialog with Image and Two Buttons
  /*
  context.showCustomDialog(
    title: "Delete Item?",
    message: "Are you sure you want to remove this item from your cart?",
    image: "assets/images/delete_warning.svg",
    confirmButtonText: "Yes, Delete",
    cancelButtonText: "Keep it",
    onConfirm: () {
      // Logic to delete
      print("Item deleted");
    },
  );
  */
  
  // 6. Show a Loading Dialog with Custom Text
  /*
  context.showCustomDialog(
    isLoading: true,
    loadingText: "Processing Payment...",
    isDismissible: false, // User cannot click outside to close
  );
  */
