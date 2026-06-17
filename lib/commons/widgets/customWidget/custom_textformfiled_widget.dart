


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

enum CustomTextFormFieldBorder { none, outline, underline }

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    // --- Core Functional Properties ---
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onFocusChanged,
    this.onDoneKeyPressed,

    // --- Behavior Properties ---
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.isPassword = false,
    this.isDropdown = false,
    this.enabled = true,
    this.autofocus = false,
    this.unfocusOnDone = true,
    this.allowOnlySingleDecimalPoint = false,
    this.inputFormatters,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.expands = false,

    // --- Border & Type ---
    this.borderType = CustomTextFormFieldBorder.none,
    this.borderRadius,
    this.borderWidth = 1.0,
    this.borderColor,

    // --- Label Styling ---
    this.labelText,
    this.labelStyle,
    this.labelFontSize,
    this.labelColor,
    this.labelFontWeight,

    // --- Hint Styling ---
    this.hintText,
    this.hintStyle,
    this.hintFontSize,
    this.hintColor,
    this.hintMaxLines,

    // --- Input Text Styling ---
    this.inputTextStyle,
    this.fontSize,
    this.textColor,
    this.fontWeight,
    this.cursorColor,

    // --- Error Styling ---
    this.errorStyle,
    this.errorFontSize,
    this.errorColor,

    // --- Icons & Extras ---
    this.prefixIcon,
    this.prefixIconUrl, // Future implementation support
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.counterStyle,

    // --- Decoration ---
    this.fillColor,
    this.contentPadding,
    this.boxShadow,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.border,
    this.isDense = true,
    this.textAlign = TextAlign.start,
    this.enableShake = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onFocusChanged;
  final VoidCallback? onDoneKeyPressed;

  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final bool isPassword;
  final bool isDropdown;
  final bool enabled;
  final bool autofocus;
  final bool unfocusOnDone;
  final bool allowOnlySingleDecimalPoint;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final int? hintMaxLines;
  final int? minLines;
  final bool expands;
  final TextAlign textAlign;

  final CustomTextFormFieldBorder borderType;
  final double? borderRadius;
  final double borderWidth;
  final Color? borderColor;

  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final String? prefixIconUrl;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;

  final TextStyle? labelStyle;
  final double? labelFontSize;
  final Color? labelColor;
  final FontWeight? labelFontWeight;
  final TextStyle? hintStyle;
  final double? hintFontSize;
  final Color? hintColor;
  final TextStyle? inputTextStyle;
  final double? fontSize;
  final Color? textColor;
  final FontWeight? fontWeight;
  final Color? cursorColor;
  final TextStyle? errorStyle;
  final double? errorFontSize;
  final Color? errorColor;
  final TextStyle? counterStyle;

  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final List<BoxShadow>? boxShadow;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? border;
  final bool isDense;

  final bool enableShake;

  @override
  State<CustomTextField> createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> shake() async {
    if (!mounted || _shakeController.isAnimating) return;
    if (widget.enableShake) {
      _shakeController.forward(from: 0);
      await HapticFeedback.heavyImpact();
    }
  }

  InputBorder _getBorder(Color color, {double? width}) {
    final radius = widget.borderRadius ?? 16;
    final stroke = width ?? widget.borderWidth;

    switch (widget.borderType) {
      case CustomTextFormFieldBorder.none:
        return OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide.none);
      case CustomTextFormFieldBorder.underline:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: color, width: stroke),
        );
      case CustomTextFormFieldBorder.outline:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: stroke),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // --- Suffix Icon Logic ---
    Widget? finalSuffixIcon;
    if (widget.isPassword) {
      finalSuffixIcon = IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscureText = !_obscureText),
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      );
    } else if (widget.isDropdown) {
      finalSuffixIcon = Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onSurface);
    } else {
      finalSuffixIcon = widget.suffixIcon;
    }

    // --- Input Formatters Logic ---
    final inputFormatters = <TextInputFormatter>[...(widget.inputFormatters ?? [])];
    if (widget.allowOnlySingleDecimalPoint) {
      inputFormatters.insert(0, FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')));
    }

    // --- Style Merging ---
    final effectiveLabelStyle = (widget.labelStyle ?? theme.textTheme.labelMedium!).copyWith(
      fontSize: widget.labelFontSize?.sp(context),
      color: widget.labelColor ?? colorScheme.onSurface.withValues(alpha: 0.7),
      fontWeight: widget.labelFontWeight ?? FontWeight.bold,
    );

    final effectiveInputStyle = (widget.inputTextStyle ?? theme.textTheme.bodyLarge!).copyWith(
      fontSize: widget.fontSize?.sp(context) ?? 16.sp(context),
      color: widget.textColor ?? colorScheme.onSurface,
      fontWeight: widget.fontWeight ?? FontWeight.w400,
    );

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(offset: Offset(_shakeAnimation.value, 0), child: child),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelText != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(widget.labelText!, style: effectiveLabelStyle),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 16.sp(context)),
              boxShadow:
                  widget.boxShadow ?? [if (widget.borderType == CustomTextFormFieldBorder.none) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: TextFormField(
              //textAlign: TextAlign.center,
              //textAlignVertical: TextAlignVertical.center,
              textAlign: widget.textAlign,
              controller: widget.controller,
              focusNode: widget.focusNode,
              maxLength: widget.maxLength,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              expands: widget.expands,
              textCapitalization: widget.textCapitalization,
              validator: (v) {
                final error = widget.validator?.call(v);
                if (error != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => shake());
                }
                return error;
              },
              onChanged: widget.onChanged,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword && _obscureText,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
                widget.onFocusChanged?.call();
              },
              // Multi-line behavior
              minLines: widget.minLines ?? 1,
              maxLines: widget.maxLines ?? (widget.keyboardType == TextInputType.multiline ? 4 : 1),

              style: effectiveInputStyle,
              cursorColor: widget.cursorColor ?? theme.primaryColor,
              inputFormatters: inputFormatters,

              textInputAction: widget.textInputAction ?? (widget.nextFocus != null ? TextInputAction.next : TextInputAction.done),

              onFieldSubmitted: (value) {
                widget.onFieldSubmitted?.call(value);
                if (widget.nextFocus != null) {
                  FocusScope.of(context).requestFocus(widget.nextFocus);
                } else {
                  if (widget.unfocusOnDone) widget.focusNode?.unfocus();
                  widget.onDoneKeyPressed?.call();
                }
              },

              decoration: InputDecoration(
                hintText: widget.hintText,
                hintMaxLines: widget.hintMaxLines ?? 1,
                hintStyle: (widget.hintStyle ?? const TextStyle()).copyWith(fontSize: widget.hintFontSize?.sp(context), color: widget.hintColor ?? theme.hintColor.withValues(alpha: 0.8)),
                errorStyle: widget.errorStyle ?? TextStyle(fontSize: 12.sp(context), color: colorScheme.error),
                fillColor: widget.fillColor ?? (widget.borderType == CustomTextFormFieldBorder.none ? Colors.white : Colors.transparent),
                filled: widget.fillColor != null || widget.borderType == CustomTextFormFieldBorder.none,
                isDense: widget.isDense,
                contentPadding: widget.contentPadding ?? const EdgeInsets.all(20),
                counterText: '',

                // Borders
                border: widget.border ?? _getBorder(widget.borderColor ?? theme.dividerColor),
                enabledBorder: widget.enabledBorder ?? _getBorder(widget.borderColor ?? theme.dividerColor.withValues(alpha: 0.1)),
                focusedBorder: widget.focusedBorder ?? _getBorder(theme.primaryColor, width: 2),
                errorBorder: widget.errorBorder ?? _getBorder(colorScheme.error),

                prefixIcon: widget.prefixIcon,
                prefixText: widget.prefixText,
                suffixText: widget.suffixText,
                suffixIcon: finalSuffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:omkar_sale/core/theme/color.dart';
// import 'package:omkar_sale/utils/extensions/num_extensions.dart';
// import 'package:omkar_sale/utils/extensions/theme_extensions.dart';

// enum CustomTextFormFieldBorder { none, outline, underline }

// class CustomTextField extends StatefulWidget {
//   const CustomTextField({
//     super.key,
//     // --- Functional Properties ---
//     this.controller,
//     this.focusNode,
//     this.nextFocus,
//     this.validator,
//     this.onChanged,
//     this.onFieldSubmitted,
//     this.onTap,
//     this.keyboardType = TextInputType.text,
//     this.textInputAction,
//     this.readOnly = false,
//     this.isPassword = false,
//     this.enabled = true,
//     this.autofocus = false,
//     this.maxLength,
//     this.maxLines = 1,
//     this.minLines,

//     // --- Border & Type ---
//     this.borderType = CustomTextFormFieldBorder.none,
//     this.borderRadius,
//     this.borderWidth = 1.0,
//     this.borderColor,

//     // --- Label Styling ---
//     this.labelText,
//     this.labelStyle,
//     this.labelFontSize,
//     this.labelColor,
//     this.labelFontWeight,

//     // --- Hint Styling ---
//     this.hintText,
//     this.hintStyle,
//     this.hintFontSize,
//     this.hintColor,

//     // --- Input Text Styling ---
//     this.inputTextStyle,
//     this.fontSize,
//     this.textColor,
//     this.fontWeight,

//     // --- Error Styling ---
//     this.errorStyle,
//     this.errorFontSize,
//     this.errorColor,

//     // --- Icons & Extras ---
//     this.prefixIcon,
//     this.suffixIcon,
//     this.prefixText,
//     this.suffixText,
//     this.counterStyle,

//     // --- Decoration ---
//     this.fillColor,
//     this.contentPadding,
//     this.boxShadow,
//     this.enabledBorder,
//     this.focusedBorder,
//     this.errorBorder,
//     this.border,

//     this.enableShake = true,
//   });

//   final TextEditingController? controller;
//   final FocusNode? focusNode;
//   final FocusNode? nextFocus;
//   final String? Function(String?)? validator;
//   final Function(String)? onChanged;
//   final Function(String)? onFieldSubmitted;
//   final VoidCallback? onTap;
//   final TextInputType keyboardType;
//   final TextInputAction? textInputAction;
//   final bool readOnly;
//   final bool isPassword;
//   final bool enabled;
//   final bool autofocus;
//   final int? maxLength;
//   final int? maxLines;
//   final int? minLines;

//   // Border Properties
//   final CustomTextFormFieldBorder borderType;
//   final double? borderRadius;
//   final double borderWidth;
//   final Color? borderColor;

//   final String? labelText;
//   final String? hintText;
//   final Widget? prefixIcon;
//   final Widget? suffixIcon;
//   final String? prefixText;
//   final String? suffixText;

//   // Granular Styles
//   final TextStyle? labelStyle;
//   final double? labelFontSize;
//   final Color? labelColor;
//   final FontWeight? labelFontWeight;
//   final TextStyle? hintStyle;
//   final double? hintFontSize;
//   final Color? hintColor;
//   final TextStyle? inputTextStyle;
//   final double? fontSize;
//   final Color? textColor;
//   final FontWeight? fontWeight;
//   final TextStyle? errorStyle;
//   final double? errorFontSize;
//   final Color? errorColor;
//   final TextStyle? counterStyle;

//   // Custom Decoration
//   final Color? fillColor;
//   final EdgeInsetsGeometry? contentPadding;
//   final List<BoxShadow>? boxShadow;
//   final InputBorder? enabledBorder;
//   final InputBorder? focusedBorder;
//   final InputBorder? errorBorder;
//   final InputBorder? border;

//   final bool enableShake;

//   @override
//   State<CustomTextField> createState() => CustomTextFieldState();
// }

// class CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
//   late AnimationController _shakeController;
//   late Animation<double> _shakeAnimation;
//   bool _obscureText = true;

//   @override
//   void initState() {
//     super.initState();
//     _obscureText = widget.isPassword;
//     _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
//     _shakeAnimation = TweenSequence<double>([
//       TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
//       TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
//       TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
//       TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
//     ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _shakeController.dispose();
//     super.dispose();
//   }

//   void shake() {
//     if (widget.enableShake) {
//       _shakeController.forward(from: 0.0);
//       HapticFeedback.heavyImpact();
//     }
//   }

//   // Logic to build the border based on Enum
//   InputBorder _getBorder(Color color, {double? width}) {
//     final double radius = widget.borderRadius ?? 16;
//     final double stroke = width ?? widget.borderWidth;

//     switch (widget.borderType) {
//       case CustomTextFormFieldBorder.none:
//         return OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide.none);
//       case CustomTextFormFieldBorder.underline:
//         return UnderlineInputBorder(
//           borderSide: BorderSide(color: color, width: stroke),
//         );
//       case CustomTextFormFieldBorder.outline:
//         return OutlineInputBorder(
//           borderRadius: BorderRadius.circular(radius),
//           borderSide: BorderSide(color: color, width: stroke),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // Style Merging Logic
//     final TextStyle effectiveLabelStyle = (widget.labelStyle ?? theme.textTheme.labelMedium!).copyWith(
//       fontSize: widget.labelFontSize?.sp(context),
//       color: widget.labelColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
//       fontWeight: widget.labelFontWeight ?? FontWeight.bold,
//     );

//     final TextStyle effectiveInputStyle = (widget.inputTextStyle ?? theme.textTheme.bodyLarge!).copyWith(
//       fontSize: widget.fontSize?.sp(context) ?? 16.sp(context),
//       color: widget.textColor,
//       fontWeight: widget.fontWeight ?? FontWeight.w600,
//     );

//     return AnimatedBuilder(
//       animation: _shakeAnimation,
//       builder: (context, child) => Transform.translate(offset: Offset(_shakeAnimation.value, 0), child: child),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (widget.labelText != null) ...[
//             Padding(
//               padding: const EdgeInsets.only(left: 4, bottom: 8),
//               child: Text(widget.labelText!, style: effectiveLabelStyle),
//             ),
//           ],
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
//               boxShadow:
//                   widget.boxShadow ?? [if (widget.borderType == CustomTextFormFieldBorder.none) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
//             ),
//             child: TextFormField(
//               controller: widget.controller,
//               focusNode: widget.focusNode,
//               validator: (v) {
//                 final error = widget.validator?.call(v);
//                 if (error != null) shake();
//                 return error;
//               },
//               onChanged: widget.onChanged,
//               keyboardType: widget.keyboardType,
//               obscureText: _obscureText,
//               maxLines: (widget.controller?.text.isEmpty ?? true) ? 1 : widget.maxLines,
//               readOnly: widget.readOnly,
//               style: effectiveInputStyle,
//               decoration: InputDecoration(
//                 hintText: widget.hintText,
//                 hintMaxLines: 1,
//                 hintStyle: (widget.hintStyle ?? const TextStyle()).copyWith(fontSize: widget.hintFontSize?.sp(context), color: widget.hintColor ?? theme.hintColor.withValues(alpha: 0.4)),
//                 fillColor: widget.fillColor ?? (widget.borderType == CustomTextFormFieldBorder.none ? Colors.white : Colors.transparent),
//                 filled: true,
//                 contentPadding: widget.contentPadding ?? const EdgeInsets.all(20),

//                 // Borders using the Helper Method + Manual Overrides
//                 border: widget.border ?? _getBorder(widget.borderColor ?? theme.dividerColor),
//                 enabledBorder: widget.enabledBorder ?? _getBorder(widget.borderColor ?? theme.dividerColor.withValues(alpha: 0.2)),
//                 focusedBorder: widget.focusedBorder ?? _getBorder(theme.primaryColor, width: 2.0),
//                 errorBorder: widget.errorBorder ?? _getBorder(theme.colorScheme.error),

//                 prefixIcon: widget.prefixIcon,
//                 suffixIcon: widget.isPassword
//                     ? IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureText = !_obscureText))
//                     : widget.suffixIcon,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:omkar_sale/core/theme/color.dart';
// // import 'package:omkar_sale/utils/extensions/num_extensions.dart';
// // import 'package:omkar_sale/utils/extensions/theme_extensions.dart';

// // enum CustomTextFormFieldBorder { none, outline, underline }

// // class CustomTextField extends StatefulWidget {
// //   const CustomTextField({
// //     super.key,
// //     this.controller,
// //     this.hintText,
// //     this.labelText,
// //     this.validator,
// //     this.isPassword = false,
// //     this.keyboardType = TextInputType.text,
// //     this.textInputAction,
// //     this.prefixIcon,
// //     this.suffixIcon,
// //     this.onChanged,
// //     this.onFieldSubmitted,
// //     this.focusNode,
// //     this.nextFocus,
// //     this.readOnly = false,
// //     this.fillColor,
// //     this.borderRadius = 16.0,
// //     this.borderType = CustomTextFormFieldBorder.none,
// //     this.maxLines = 1,
// //     this.minLines,
// //     this.maxLength,
// //     this.contentPadding,
// //     // New Font Size Options
// //     this.labelFontSize,
// //     this.hintFontSize,
// //     this.fontSize,
// //     this.errorFontSize,
// //   });

// //   final TextEditingController? controller;
// //   final String? hintText;
// //   final String? labelText;
// //   final String? Function(String?)? validator;
// //   final bool isPassword;
// //   final TextInputType keyboardType;
// //   final TextInputAction? textInputAction;
// //   final Widget? prefixIcon;
// //   final Widget? suffixIcon;
// //   final Function(String)? onChanged;
// //   final Function(String)? onFieldSubmitted;
// //   final FocusNode? focusNode;
// //   final FocusNode? nextFocus;
// //   final bool readOnly;
// //   final Color? fillColor;
// //   final double borderRadius;
// //   final CustomTextFormFieldBorder borderType;
// //   final int? maxLines;
// //   final int? minLines;
// //   final int? maxLength;
// //   final EdgeInsetsGeometry? contentPadding;

// //   // Font Size properties
// //   final double? labelFontSize;
// //   final double? hintFontSize;
// //   final double? fontSize;
// //   final double? errorFontSize;

// //   @override
// //   State<CustomTextField> createState() => AppTextFieldState();
// // }

// // class AppTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
// //   late AnimationController _shakeController;
// //   late Animation<double> _shakeAnimation;
// //   bool _obscureText = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _obscureText = widget.isPassword;

// //     _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

// //     _shakeAnimation = TweenSequence<double>([
// //       TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
// //       TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
// //       TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
// //       TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
// //     ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
// //   }

// //   @override
// //   void dispose() {
// //     _shakeController.dispose();
// //     super.dispose();
// //   }

// //   void shake() {
// //     _shakeController.forward(from: 0.0);
// //     HapticFeedback.heavyImpact();
// //     HapticFeedback.vibrate();
// //   }

// //   InputBorder _buildBorder(Color color, {double width = 1.0}) {
// //     switch (widget.borderType) {
// //       case CustomTextFormFieldBorder.none:
// //         return OutlineInputBorder(borderRadius: BorderRadius.circular(widget.borderRadius), borderSide: BorderSide.none);
// //       case CustomTextFormFieldBorder.underline:
// //         return UnderlineInputBorder(
// //           borderSide: BorderSide(color: color, width: width),
// //         );
// //       case CustomTextFormFieldBorder.outline:
// //         return OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(widget.borderRadius),
// //           borderSide: BorderSide(color: color, width: width),
// //         );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);

// //     return AnimatedBuilder(
// //       animation: _shakeAnimation,
// //       builder: (context, child) {
// //         return Transform.translate(offset: Offset(_shakeAnimation.value, 0), child: child);
// //       },
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           if (widget.labelText != null) ...[
// //             Text(
// //               widget.labelText!,
// //               style: theme.textTheme.labelMedium?.copyWith(
// //                 fontWeight: FontWeight.bold,
// //                 color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
// //                 fontSize: widget.labelFontSize?.sp(context), // Custom or default
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //           ],
// //           Container(
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(widget.borderRadius),
// //               boxShadow: [
// //                 if (widget.borderType == CustomTextFormFieldBorder.none) BoxShadow(color: AppThemeColors.darkBlackTextColor.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5)),
// //               ],
// //             ),
// //             child: TextFormField(
// //               controller: widget.controller,
// //               focusNode: widget.focusNode,
// //               validator: (value) {
// //                 final error = widget.validator?.call(value);
// //                 if (error != null) shake();
// //                 return error;
// //               },
// //               obscureText: _obscureText,
// //               keyboardType: widget.keyboardType,
// //               textInputAction: widget.textInputAction ?? (widget.nextFocus != null ? TextInputAction.next : TextInputAction.done),
// //               onFieldSubmitted: (value) {
// //                 if (widget.nextFocus != null) {
// //                   FocusScope.of(context).requestFocus(widget.nextFocus);
// //                 }
// //                 widget.onFieldSubmitted?.call(value);
// //               },
// //               onTapOutside: (event) {
// //                 FocusManager.instance.primaryFocus?.unfocus();
// //               },
// //               onChanged: widget.onChanged,
// //               readOnly: widget.readOnly,
// //               maxLines: widget.maxLines,
// //               minLines: widget.minLines,
// //               maxLength: widget.maxLength,
// //               // User Input Style
// //               style: theme.textTheme.bodyLarge?.copyWith(fontSize: widget.fontSize?.sp(context)),
// //               decoration: InputDecoration(
// //                 hintText: widget.hintText,
// //                 // Hint Style
// //                 hintStyle: TextStyle(color: theme.hintColor.withValues(alpha: 0.4), fontSize: (widget.hintFontSize ?? 16).sp(context)),
// //                 // Error Style
// //                 errorStyle: TextStyle(fontSize: widget.errorFontSize?.sp(context)),
// //                 fillColor: widget.fillColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
// //                 filled: true,
// //                 isDense: true,
// //                 contentPadding: widget.contentPadding ?? const EdgeInsets.all(18),

// //                 border: _buildBorder(theme.dividerColor),
// //                 enabledBorder: _buildBorder(theme.dividerColor.withValues(alpha: 0.1)),
// //                 focusedBorder: _buildBorder(theme.primaryColor, width: 2),
// //                 errorBorder: _buildBorder(theme.colorScheme.error),

// //                 prefixIcon: widget.prefixIcon,
// //                 suffixIcon: widget.isPassword
// //                     ? IconButton(
// //                         icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
// //                         onPressed: () => setState(() => _obscureText = !_obscureText),
// //                         color: context.colorScheme.onSurface.withValues(alpha: 0.4),
// //                       )
// //                     : widget.suffixIcon,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
