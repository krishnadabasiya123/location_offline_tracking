import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

enum DropdownBorderType { underline, outline, rounded, none }

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({
    required this.items,
    required this.controller,
    required this.hintText,
    required this.isEnabled,
    this.imageURL,
    super.key,
    this.onSelected,
    this.initialSelection,
    this.bottomPadding,
    this.width,
    this.height = 50,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.menuBackgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textStyle,
    this.hintStyle,
    this.menuItemStyle,
    this.iconSize = 24,
    this.iconColor,
    this.borderType = DropdownBorderType.underline,
    this.showSelectedIcon = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.elevation = 8.0,
    this.contentPadding,
    this.menuPadding,
    this.errorText,
    this.errorStyle,
  });

  final List<Map<String, dynamic>> items;
  final TextEditingController controller;
  final String hintText;
  final String? imageURL;
  final String? initialSelection;
  final void Function(String value, String label)? onSelected;
  final bool isEnabled;
  final double? bottomPadding;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? menuBackgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? menuItemStyle;
  final double iconSize;
  final Color? iconColor;
  final DropdownBorderType borderType;
  final bool showSelectedIcon;
  final Duration animationDuration;
  final double elevation;
  final EdgeInsets? contentPadding;
  final EdgeInsets? menuPadding;
  final String? errorText;
  final TextStyle? errorStyle;

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: widget.animationDuration);
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  InputBorder _buildBorder({required bool isPrimaryBorder, bool? isErrorBorder}) {
    final color = (isErrorBorder ?? false)
        ? Colors.red
        : isPrimaryBorder
        ? (widget.focusedBorderColor ?? Theme.of(context).primaryColor)
        : (widget.borderColor ?? Colors.grey.withValues(alpha: 0.5));

    final borderSide = BorderSide(color: color, width: isPrimaryBorder ? 1.5 : 1.0);

    switch (widget.borderType) {
      case DropdownBorderType.underline:
        return UnderlineInputBorder(borderSide: borderSide);
      case DropdownBorderType.outline:
        return OutlineInputBorder(borderSide: borderSide, borderRadius: BorderRadius.circular(widget.borderRadius));
      case DropdownBorderType.rounded:
        return OutlineInputBorder(borderSide: borderSide, borderRadius: BorderRadius.circular(widget.borderRadius * 4));
      case DropdownBorderType.none:
        return InputBorder.none;
    }
  }

  Widget _buildImageWidget() {
    if (widget.imageURL == null) return const SizedBox.shrink();
    if (widget.imageURL!.startsWith('http')) {
      return Image.network(widget.imageURL!, width: widget.iconSize, height: widget.iconSize, fit: BoxFit.contain);
    } else if (widget.imageURL!.contains('/')) {
      return Image.asset(widget.imageURL!, width: widget.iconSize, height: widget.iconSize, fit: BoxFit.contain);
    } else {
      return Text(widget.imageURL!, style: TextStyle(fontSize: widget.iconSize));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      expandedInsets: EdgeInsets.zero,
      initialSelection: widget.initialSelection,
      enabled: widget.isEnabled,
      // width: dropdownWidth,
      controller: widget.controller,
      hintText: widget.hintText,
      textStyle: widget.textStyle,
      leadingIcon: widget.imageURL != null
          ? Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildImageWidget(),
            )
          : null,
      onSelected: (val) {
        setState(() {
          if (val != null) {
            final selectedItem = widget.items.firstWhere((e) => e['value'].toString() == val);
            final label = selectedItem['label'].toString();

            // Update the parent via the callback
            if (widget.onSelected != null) {
              widget.onSelected!(val, label);
            }
          }
        });
      },
      selectedTrailingIcon: RotationTransition(
        turns: _rotateAnimation,
        child: Icon(Icons.keyboard_arrow_down, color: widget.iconColor, size: widget.iconSize),
      ),
      trailingIcon: Icon(Icons.keyboard_arrow_down, color: widget.iconColor, size: widget.iconSize),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(widget.menuBackgroundColor ?? Colors.white),
        elevation: WidgetStatePropertyAll(widget.elevation),
        padding: widget.menuPadding != null ? WidgetStatePropertyAll(widget.menuPadding) : null,
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: widget.backgroundColor != null,
        fillColor: widget.backgroundColor,
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16),
        constraints: BoxConstraints(maxHeight: widget.height),
        hintStyle: widget.hintStyle,
        errorStyle: widget.errorStyle,
        enabledBorder: _buildBorder(isPrimaryBorder: false),
        focusedBorder: _buildBorder(isPrimaryBorder: true),
        errorBorder: _buildBorder(isPrimaryBorder: false, isErrorBorder: true),
        border: _buildBorder(isPrimaryBorder: false),
      ),
      dropdownMenuEntries: widget.items.map((item) {
        return DropdownMenuEntry<String>(
          value: item['value'].toString(),
          label: item['label'].toString(),
          leadingIcon: item['leadingIcon'] as Widget?,
          trailingIcon: (widget.showSelectedIcon && (widget.controller.text == item['label'])) ? Icon(Icons.check, size: 16.sp(context), color: Theme.of(context).primaryColor) : null,
          style: MenuItemButton.styleFrom(
            textStyle: widget.menuItemStyle,
            foregroundColor: widget.menuItemStyle?.color,
          ),
        );
      }).toList(),
    );
  }
}

class DropdownConfig {
  static List<Map<String, dynamic>> fromStringList(List<String> items) {
    return items.map((item) => {'value': item, 'label': item}).toList();
  }
}

extension DropdownItemsExtension on List<Map<String, dynamic>> {
  List<Map<String, dynamic>> toDropdownItems() {
    return map(
      (item) => {
        'value': item['value'],
        'label': item['label'] ?? item['value'],
        'enabled': item['enabled'] ?? true,
        'leadingIcon': item['leadingIcon'],
      },
    ).toList();
  }
}

// import 'package:flutter/material.dart';

// /// Enhanced custom dropdown widget with improved functionality and customization
// class CustomDropdown extends StatefulWidget {
//   const CustomDropdown({
//     required this.items,
//     required this.controller,
//     required this.hintText,
//     required this.isEnabled,
//     this.imageURL,
//     super.key,
//     this.onSelected,
//     this.initialSelection,
//     this.bottomPadding,
//     this.width,
//     this.height = 50,
//     this.borderRadius = 8.0,
//     this.backgroundColor,
//     this.menuBackgroundColor,
//     this.borderColor,
//     this.focusedBorderColor,
//     this.textStyle,
//     this.hintStyle,
//     this.menuItemStyle,
//     this.iconSize = 24,
//     this.iconColor,
//     this.borderType = DropdownBorderType.underline,
//     this.showSelectedIcon = true,
//     this.animationDuration = const Duration(milliseconds: 250),
//     this.elevation = 8.0,
//     this.contentPadding,
//     this.menuPadding,
//     this.errorText,
//     this.errorStyle,
//   });

//   // Core properties
//   final List<Map<String, dynamic>> items;
//   final TextEditingController controller;
//   final String hintText;
//   final String? imageURL;
//   final String? initialSelection;
//   final void Function(String value, String label)? onSelected;
//   final bool isEnabled;

//   // Styling properties
//   final double? bottomPadding;
//   final double? width;
//   final double height;
//   final double borderRadius;
//   final Color? backgroundColor;
//   final Color? menuBackgroundColor;
//   final Color? borderColor;
//   final Color? focusedBorderColor;
//   final TextStyle? textStyle;
//   final TextStyle? hintStyle;
//   final TextStyle? menuItemStyle;
//   final double iconSize;
//   final Color? iconColor;
//   final DropdownBorderType borderType;
//   final bool showSelectedIcon;
//   final Duration animationDuration;
//   final double elevation;
//   final EdgeInsets? contentPadding;
//   final EdgeInsets? menuPadding;

//   // Error handling
//   final String? errorText;
//   final TextStyle? errorStyle;

//   @override
//   State<CustomDropdown> createState() => _CustomDropdownState();
// }

// class _CustomDropdownState extends State<CustomDropdown> with TickerProviderStateMixin {
//   late AnimationController _rotationController;
//   late Animation<double> _rotateAnimation;
//   bool _isOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     _rotationController = AnimationController(
//       vsync: this,
//       duration: widget.animationDuration,
//     );
//     _rotateAnimation =
//         Tween<double>(
//           begin: 0,
//           end: 0.5,
//         ).animate(
//           CurvedAnimation(
//             parent: _rotationController,
//             curve: Curves.easeInOut,
//           ),
//         );
//   }

//   @override
//   void dispose() {
//     _rotationController.dispose();
//     super.dispose();
//   }

//   void _toggleDropdown(bool isOpen) {
//     setState(() {
//       _isOpen = isOpen;
//     });
//     if (isOpen) {
//       _rotationController.forward();
//     } else {
//       _rotationController.reverse();
//     }
//   }

//   InputBorder _buildBorder({
//     required bool isPrimaryBorder,
//     bool? isErrorBorder,
//   }) {
//     final color = _getBorderColor(isPrimaryBorder, isErrorBorder);
//     final borderSide = BorderSide(
//       color: color,
//       width: isPrimaryBorder ? 2.0 : 1.0,
//     );

//     switch (widget.borderType) {
//       case DropdownBorderType.underline:
//         return UnderlineInputBorder(
//           borderSide: borderSide,
//           borderRadius: BorderRadius.circular(widget.borderRadius),
//         );
//       case DropdownBorderType.outline:
//         return OutlineInputBorder(
//           borderSide: borderSide,
//           borderRadius: BorderRadius.circular(widget.borderRadius),
//         );
//       case DropdownBorderType.rounded:
//         return OutlineInputBorder(
//           borderSide: borderSide,
//           borderRadius: BorderRadius.circular(widget.borderRadius * 3),
//         );
//       case DropdownBorderType.none:
//         return InputBorder.none;
//     }
//   }

//   Color _getBorderColor(bool isPrimaryBorder, bool? isErrorBorder) {
//     if (isErrorBorder ?? false) {
//       return Theme.of(context).colorScheme.error;
//     }
//     if (isPrimaryBorder) {
//       return widget.focusedBorderColor ?? Theme.of(context).colorScheme.primary;
//     }
//     return widget.borderColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
//   }

//   Widget _buildLeadingIcon() {
//     return Align(
//       heightFactor: 1,
//       widthFactor: 1,
//       child: SizedBox(
//         height: widget.iconSize,
//         width: widget.iconSize,
//         child: _buildImageWidget(),
//       ),
//     );
//   }

//   Widget _buildImageWidget() {
//     if (widget.imageURL == null) {
//       return const SizedBox.shrink();
//     }
//     // Handle different image types
//     if (widget.imageURL!.startsWith('http')) {
//       return Image.network(
//         widget.imageURL!,
//         width: widget.iconSize,
//         height: widget.iconSize,
//         fit: BoxFit.contain,
//         errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: widget.iconSize),
//       );
//     } else if (widget.imageURL!.contains('/')) {
//       return Image.asset(
//         widget.imageURL!,
//         width: widget.iconSize,
//         height: widget.iconSize,
//         fit: BoxFit.contain,
//         errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: widget.iconSize),
//       );
//     } else {
//       // Assume it's an icon name or emoji
//       return Text(widget.imageURL!, style: TextStyle(fontSize: widget.iconSize));
//     }
//   }

//   Widget _buildTrailingIcon(bool isSelected) {
//     return RotationTransition(
//       turns: _rotateAnimation,
//       child: Icon(
//         isSelected ? Icons.keyboard_arrow_up_sharp : Icons.keyboard_arrow_down_sharp,
//         color: widget.iconColor ?? Theme.of(context).colorScheme.onSurface,
//         size: 16,
//       ),
//     );
//   }

//   TextStyle _getTextStyle(bool isHint) {
//     final baseColor = Theme.of(context).colorScheme.onSurface;
//     final defaultStyle = TextStyle(
//       color: baseColor,
//       fontSize: 14,
//     );

//     if (isHint) {
//       return widget.hintStyle ??
//           defaultStyle.copyWith(
//             fontSize: 12,
//             color: baseColor.withValues(alpha: 0.5),
//           );
//     }
//     return widget.textStyle ?? defaultStyle;
//   }

//   MenuStyle _buildMenuStyle() {
//     final dropdownWidth = _calculateWidth();
//     return MenuStyle(
//       fixedSize: WidgetStatePropertyAll(Size(dropdownWidth, double.nan)),
//       maximumSize: WidgetStatePropertyAll(Size(dropdownWidth, double.infinity)),
//       minimumSize: WidgetStatePropertyAll(Size(dropdownWidth, 0)),
//       backgroundColor: WidgetStatePropertyAll(
//         widget.menuBackgroundColor ?? Theme.of(context).colorScheme.surface,
//       ),
//       elevation: WidgetStatePropertyAll(widget.elevation),
//       padding: widget.menuPadding != null ? WidgetStatePropertyAll(widget.menuPadding) : null,
//       shape: WidgetStatePropertyAll(
//         RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(widget.borderRadius),
//         ),
//       ),
//     );
//   }

//   List<DropdownMenuEntry<String>> _buildMenuEntries() {
//     return widget.items.map<DropdownMenuEntry<String>>(
//       (Map<String, dynamic> item) {
//         final value = item['value'] as String;
//         final label = item['label']?.toString() ?? value;
//         final isSelected = widget.controller.text == value;

//         return DropdownMenuEntry<String>(
//           value: value,
//           label: label,
//           leadingIcon: item['leadingIcon'] as Widget?,
//           trailingIcon: widget.showSelectedIcon && isSelected
//               ? Icon(
//                   Icons.check,
//                   color: Theme.of(context).colorScheme.primary,
//                   size: 16,
//                 )
//               : item['trailingIcon'] as Widget?,
//           enabled: item['enabled'] as bool? ?? true,
//           style: MenuItemButton.styleFrom(
//             foregroundColor: widget.menuItemStyle?.color ?? Theme.of(context).colorScheme.onSurface,
//             textStyle: widget.menuItemStyle,
//             padding: widget.contentPadding,
//           ),
//         );
//       },
//     ).toList();
//   }

//   void _handleSelection(String? value) {
//     _toggleDropdown(false);
//     // Remove focus for better UX
//     FocusScope.of(context).unfocus();

//     if (value == null) return;
//     final selectedItem = widget.items.cast<Map<String, Object>>().firstWhere(
//       (item) => item['value']?.toString() == value,
//       orElse: () => {'value': value, 'label': value},
//     );

//     final label = selectedItem['label']?.toString() ?? value;

//     // Call old callback for backward compatibility
//     if (widget.onSelected != null) {
//       widget.onSelected!(value, label);
//     }
//   }

//   double _calculateWidth() {
//     if (widget.width != null) return widget.width!;

//     // Fallback calculation if context extensions are not available
//     return MediaQuery.of(context).size.width - 32; // Default padding
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dropdown = DropdownMenu<String>(
//       initialSelection: widget.initialSelection,
//       enabled: widget.isEnabled,
//       width: _calculateWidth(),
//       textStyle: _getTextStyle(false),
//       requestFocusOnTap: false,
//       leadingIcon: _buildLeadingIcon(),
//       onSelected: _handleSelection,
//       menuStyle: _buildMenuStyle(),
//       hintText: widget.hintText,
//       controller: widget.controller,
//       selectedTrailingIcon: _buildTrailingIcon(true),
//       trailingIcon: _buildTrailingIcon(false),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: widget.backgroundColor != null,
//         fillColor: widget.backgroundColor,
//         contentPadding: widget.contentPadding ?? EdgeInsets.zero,
//         constraints: BoxConstraints(maxHeight: widget.height),
//         hintStyle: _getTextStyle(true),
//         errorStyle: widget.errorStyle,
//         errorBorder: _buildBorder(isPrimaryBorder: false, isErrorBorder: true),
//         focusedErrorBorder: _buildBorder(isPrimaryBorder: true, isErrorBorder: true),
//         enabledBorder: _buildBorder(isPrimaryBorder: false),
//         disabledBorder: _buildBorder(isPrimaryBorder: false),
//         focusedBorder: _buildBorder(isPrimaryBorder: true),
//       ),
//       dropdownMenuEntries: _buildMenuEntries(),
//     );

//     return widget.bottomPadding != null
//         ? Padding(
//             padding: EdgeInsets.only(bottom: widget.bottomPadding!),
//             child: dropdown,
//           )
//         : dropdown;
//   }
// }

// /// Border types for dropdown
// enum DropdownBorderType {
//   underline,
//   outline,
//   rounded,
//   none,
// }

// /// Extension for easier usage with Map data
// extension DropdownItemsExtension on List<Map<String, dynamic>> {
//   /// Convert list of maps to dropdown-compatible format
//   List<Map<String, dynamic>> toDropdownItems() {
//     return map((item) {
//       return {
//         'value': item['value'],
//         'label': item['label'] ?? item['value'],
//         'enabled': item['enabled'] ?? true,
//         'leadingIcon': item['leadingIcon'],
//         'trailingIcon': item['trailingIcon'],
//       };
//     }).toList();
//   }
// }

// /// Utility class for common dropdown configurations
// class DropdownConfig {
//   /// Create a simple text-based dropdown configuration
//   static List<Map<String, dynamic>> fromStringList(List<String> items) {
//     return items
//         .map(
//           (item) => {
//             'value': item,
//             'label': item,
//             'enabled': true,
//           },
//         )
//         .toList();
//   }

//   /// Create dropdown configuration with icons
//   static List<Map<String, dynamic>> withIcons({
//     required List<String> values,
//     required List<String> labels,
//     List<Widget>? icons,
//   }) {
//     assert(values.length == labels.length);
//     assert(icons == null || icons.length == values.length);

//     return List.generate(
//       values.length,
//       (index) => {
//         'value': values[index],
//         'label': labels[index],
//         'enabled': true,
//         'leadingIcon': icons?[index],
//       },
//     );
//   }

//   /// Create dropdown configuration with custom properties
//   static List<Map<String, dynamic>> custom({
//     required List<String> values,
//     required List<String> labels,
//     List<bool>? enabled,
//     List<Widget>? leadingIcons,
//     List<Widget>? trailingIcons,
//   }) {
//     assert(values.length == labels.length);
//     assert(enabled == null || enabled.length == values.length);
//     assert(leadingIcons == null || leadingIcons.length == values.length);
//     assert(trailingIcons == null || trailingIcons.length == values.length);

//     return List.generate(
//       values.length,
//       (index) => {
//         'value': values[index],
//         'label': labels[index],
//         'enabled': enabled?[index] ?? true,
//         'leadingIcon': leadingIcons?[index],
//         'trailingIcon': trailingIcons?[index],
//       },
//     );
//   }
// }
