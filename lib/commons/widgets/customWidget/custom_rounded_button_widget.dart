import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Determines the position of the icon relative to the text.
enum ButtonIconPosition { leading, trailing }

/// A modern, customizable button with scale animations and haptic feedback.
class CustomRoundedButtonWidget extends StatefulWidget {
  const CustomRoundedButtonWidget({
    required this.onPressed,
    super.key,
    this.text,
    this.icon,
    this.child,
    // Style
    this.height = 52.0,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.borderRadius,
    this.borderSide,
    this.elevation = 0,
    this.shadowColor,
    // Behavior
    this.isLoading = false,
    this.isEnabled = true,
    this.stretch = false,
    this.useHapticFeedback = true,
    this.iconPosition = ButtonIconPosition.leading,
    this.padding,
    this.textStyle,
  }) : assert(child != null || text != null, 'Button must have either text or a child');
  // --- 1. Primary Style Constructor ---
  factory CustomRoundedButtonWidget.primary({required String text, required VoidCallback? onPressed, Widget? icon, bool isLoading = false, bool stretch = false}) =>
      CustomRoundedButtonWidget(text: text, onPressed: onPressed, icon: icon, isLoading: isLoading, stretch: stretch, backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, elevation: 4);

  // --- 2. Outline Style Constructor ---
  factory CustomRoundedButtonWidget.outline({required String text, required VoidCallback? onPressed, Widget? icon, bool stretch = false}) => CustomRoundedButtonWidget(
    text: text,
    onPressed: onPressed,
    icon: icon,
    stretch: stretch,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.blueAccent,
    borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
  );

  // --- 3. Premium/Gradient Constructor ---
  factory CustomRoundedButtonWidget.premium({required String text, required VoidCallback? onPressed, Widget? icon, bool isLoading = false, bool stretch = false}) => CustomRoundedButtonWidget(
    text: text,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    stretch: stretch,
    gradient: const LinearGradient(colors: [Color(0xFF642BEE), Color(0xFFF300FF)]),
    shadowColor: const Color(0xFF642BEE),
    elevation: 6,
  );

  final VoidCallback? onPressed;
  final String? text;
  final Widget? icon;
  final Widget? child;

  final double height;
  final double? width;
  final bool stretch;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final double elevation;
  final Color? shadowColor;

  final bool isLoading;
  final bool isEnabled;
  final bool useHapticFeedback;
  final ButtonIconPosition iconPosition;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  @override
  State<CustomRoundedButtonWidget> createState() => _AppButtonState();
}

// ... imports and ButtonIconPosition enum remain same ...

class _AppButtonState extends State<CustomRoundedButtonWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    // Disable scale animation if loading
    if (widget.isEnabled && !widget.isLoading && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) => _controller.reverse();
  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. VISUAL STATE: Should it look active or gray?
    // It should look active even when loading. It only looks gray if isEnabled is false or onPressed is null.
    final looksEnabled = widget.isEnabled && widget.onPressed != null;

    // 2. INTERACTION STATE: Can the user actually click it?
    final canInteract = looksEnabled && !widget.isLoading;

    final effectiveBgColor = looksEnabled ? (widget.backgroundColor ?? theme.colorScheme.primary) : (theme.disabledColor.withValues(alpha: 0.12));

    final effectiveFgColor = widget.foregroundColor ??
        widget.textStyle?.color ??
        (ThemeData.estimateBrightnessForColor(effectiveBgColor) == Brightness.dark ? Colors.white : Colors.black);

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);

    return MouseRegion(
      cursor: canInteract ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        // 3. SET ONTAP TO NULL IF LOADING
        onTap: canInteract
            ? () {
                if (widget.useHapticFeedback) HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.height,
            width: widget.stretch ? double.infinity : widget.width,
            decoration: BoxDecoration(
              color: widget.gradient == null ? effectiveBgColor : null,
              gradient: looksEnabled ? widget.gradient : null, // Keep gradient while loading
              borderRadius: borderRadius,
              border: widget.borderSide != null ? Border.fromBorderSide(widget.borderSide!) : null,
              boxShadow: [
                if (widget.elevation > 0 && looksEnabled)
                  BoxShadow(color: (widget.shadowColor ?? effectiveBgColor).withValues(alpha: 0.3), blurRadius: widget.elevation * 2, offset: Offset(0, widget.elevation)),
              ],
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
                child: Center(child: _buildContent(effectiveFgColor, theme)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color color, ThemeData theme) {
    // 4. CHANGE CONTENT TO LOADING WIDGET WITHOUT CHANGING BG
    if (widget.isLoading) {
      return SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(color)));
    }

    if (widget.child != null) return widget.child!;

    final textWidget = Text(
      widget.text!,
      style: (widget.textStyle ?? theme.textTheme.labelLarge)?.copyWith(color: color, fontWeight: FontWeight.w600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.iconPosition == ButtonIconPosition.leading) ...[_buildIcon(color), const SizedBox(width: 8)],
          textWidget,
          if (widget.iconPosition == ButtonIconPosition.trailing) ...[const SizedBox(width: 8), _buildIcon(color)],
        ],
      );
    }

    return textWidget;
  }

  Widget _buildIcon(Color color) {
    return IconTheme(
      data: IconThemeData(color: color, size: 18),
      child: widget.icon!,
    );
  }
}

// class _AppButtonState extends State<CustomRoundedButtonWidget> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 100),
//       upperBound: 0.05, // Scales down by 5%
//     );
//     _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _handleTapDown(TapDownDetails details) {
//     if (widget.isEnabled && !widget.isLoading) {
//       _controller.forward();
//     }
//   }

//   void _handleTapUp(TapUpDetails details) {
//     _controller.reverse();
//   }

//   void _handleTapCancel() {
//     _controller.reverse();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // Logic for colors
//     final isActuallyEnabled = widget.isEnabled && widget.onPressed != null && !widget.isLoading;

//     final effectiveBgColor = isActuallyEnabled ? (widget.backgroundColor ?? theme.colorScheme.primary) : (theme.disabledColor.withValues(alpha:0.12));

//     final effectiveFgColor = widget.foregroundColor ?? (ThemeData.estimateBrightnessForColor(effectiveBgColor) == Brightness.dark ? Colors.white : Colors.black);

//     final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);

//     return MouseRegion(
//       cursor: isActuallyEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
//       child: GestureDetector(
//         onTapDown: _handleTapDown,
//         onTapUp: _handleTapUp,
//         onTapCancel: _handleTapCancel,
//         onTap: isActuallyEnabled
//             ? () {
//                 if (widget.useHapticFeedback) HapticFeedback.lightImpact();
//                 widget.onPressed?.call();
//               }
//             : null,
//         child: ScaleTransition(
//           scale: _scaleAnimation,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             height: widget.height,
//             width: widget.stretch ? double.infinity : widget.width,
//             decoration: BoxDecoration(
//               color: widget.gradient == null ? effectiveBgColor : null,
//               gradient: isActuallyEnabled ? widget.gradient : null,
//               borderRadius: borderRadius,
//               border: widget.borderSide != null ? Border.fromBorderSide(widget.borderSide!) : null,
//               boxShadow: [
//                 if (widget.elevation > 0 && isActuallyEnabled)
//                   BoxShadow(color: (widget.shadowColor ?? effectiveBgColor).withValues(alpha:0.3), blurRadius: widget.elevation * 2, offset: Offset(0, widget.elevation)),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: borderRadius,
//               child: Padding(
//                 padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
//                 child: Center(child: _buildContent(effectiveFgColor, theme)),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildContent(Color color, ThemeData theme) {
//     if (widget.isLoading) {
//       return SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(color)));
//     }

//     if (widget.child != null) return widget.child!;

//     final textWidget = Text(
//       widget.text!,
//       style: (widget.textStyle ?? theme.textTheme.labelLarge)?.copyWith(color: color, fontWeight: FontWeight.w600),
//       maxLines: 1,
//       overflow: TextOverflow.ellipsis,
//     );

//     if (widget.icon != null) {
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (widget.iconPosition == ButtonIconPosition.leading) ...[_buildIcon(color), const SizedBox(width: 8)],
//           textWidget,
//           if (widget.iconPosition == ButtonIconPosition.trailing) ...[const SizedBox(width: 8), _buildIcon(color)],
//         ],
//       );
//     }

//     return textWidget;
//   }

//   Widget _buildIcon(Color color) {
//     return IconTheme(
//       data: IconThemeData(color: color, size: 18),
//       child: widget.icon!,
//     );
//   }
// }
