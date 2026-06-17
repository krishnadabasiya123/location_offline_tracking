import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    super.key,
    this.actions,
    this.onTapBackButton,
    this.elevation,
    this.appBarHeight,
    this.backgroundColor,
    // Behavior Flags
    this.automaticallyImplyLeading = true,
    this.roundedAppBar = true,
    this.usePrimaryColor = false,
    this.centerTitle = true,
  });

  /// Can be a [String] or any [Widget]
  final dynamic title;
  final double? appBarHeight;
  final List<Widget>? actions;
  final VoidCallback? onTapBackButton;
  final double? elevation;
  final Color? backgroundColor;

  final bool automaticallyImplyLeading;
  final bool roundedAppBar;
  final bool usePrimaryColor;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // --- Dynamic Color Logic ---
    final effectiveBgColor = backgroundColor ?? (colorScheme.secondary);

    final effectiveFgColor = usePrimaryColor ? theme.primaryColor : colorScheme.onTertiary;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight ?? kToolbarHeight),
      child: AppBar(
        title: title is String
            ? Text(
                title as String,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20.sp(context)),
              )
            : title as Widget,

        centerTitle: centerTitle,
        elevation: elevation ?? (roundedAppBar ? 2 : 0),
        scrolledUnderElevation: roundedAppBar ? (elevation ?? 2) : 0,

        backgroundColor: effectiveBgColor,
        surfaceTintColor: Colors.transparent, // Prevents M3 purple tint
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),

        // --- Shape Logic ---
        shape: roundedAppBar ? const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))) : null,

        // --- Leading Logic ---
        leading: automaticallyImplyLeading
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: effectiveFgColor,
                onPressed: () {
                  HapticFeedback.lightImpact(); // Modern tactile feel
                  if (onTapBackButton != null) {
                    onTapBackButton!();
                  } else {
                    Navigator.maybePop(context);
                  }
                },
              )
            : null,

        // --- Title Styling ---
        titleTextStyle: GoogleFonts.nunito(color: effectiveFgColor, fontWeight: FontWeight.bold, fontSize: 18.sp(context)),

        actions: actions != null ? [...actions!, SizedBox(width: 8.sp(context))] : null,

        // --- Status Bar Style ---
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: ThemeData.estimateBrightnessForColor(effectiveBgColor) == Brightness.dark ? Brightness.light : Brightness.dark,
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(appBarHeight ?? kToolbarHeight);
  }
}
