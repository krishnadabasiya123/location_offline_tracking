import 'package:flutter/material.dart';
import 'package:omkar_sale/core/theme/color.dart';

enum AppThemeType { dark, light }

final Map<AppThemeType, ThemeData> appThemeData = {
  AppThemeType.light: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppThemeColors.lightSurfaceColor,
    brightness: Brightness.light,
    primaryColor: AppThemeColors.lightPrimaryColor,
    secondaryHeaderColor: AppThemeColors.lightTextColor,

    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppThemeColors.lightPrimaryColor, selectionHandleColor: AppThemeColors.lightPrimaryColor),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppThemeColors.lightPrimaryColor,
      onPrimary: AppThemeColors.whiteColor,
      secondary: AppThemeColors.lightSecondaryColor,
      onSecondary: AppThemeColors.lightTextColor,
      error: AppThemeColors.errorColor,
      onError: AppThemeColors.whiteColor,

      surface: AppThemeColors.lightSurfaceColor,
      onSurface: AppThemeColors.lightTextColor,
      surfaceDim: AppThemeColors.lightGreyColor,
      onTertiary: AppThemeColors.lightTextColor,
    ),
    // Modern Date Picker Theme (Blue Header / White Body)
    datePickerTheme: DatePickerThemeData(
      headerBackgroundColor: AppThemeColors.lightPrimaryColor,
      headerForegroundColor: AppThemeColors.whiteColor,
      backgroundColor: AppThemeColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      dayStyle: const TextStyle(fontWeight: FontWeight.bold),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: AppThemeColors.lightPrimaryColor),
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: AppThemeColors.lightGreyColor),
    ),
    cardTheme: CardThemeData(
      color: AppThemeColors.lightSecondaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppThemeColors.lightGreyColor.withValues(alpha: 0.1)),
      ),
    ),

    // Modern Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeColors.lightSecondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppThemeColors.lightPrimaryColor, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppThemeColors.lightGreyColor, thickness: 0.5),
  ),
  //
  AppThemeType.dark: ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppThemeColors.darkPrimaryColor,
    secondaryHeaderColor: AppThemeColors.darkTextColor,
    scaffoldBackgroundColor: AppThemeColors.darkSurfaceColor,

    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppThemeColors.darkPrimaryColor, selectionHandleColor: AppThemeColors.darkPrimaryColor),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppThemeColors.darkPrimaryColor,
      onPrimary: AppThemeColors.whiteColor,
      secondary: AppThemeColors.darkSecondaryColor,
      onSecondary: AppThemeColors.darkTextColor,
      error: AppThemeColors.errorColor,
      onError: AppThemeColors.whiteColor,
      surface: AppThemeColors.darkSurfaceColor,
      onSurface: AppThemeColors.darkTextColor,
      surfaceDim: AppThemeColors.darkGreyColor,
      onTertiary: AppThemeColors.darkTextColor,
    ),
    datePickerTheme: DatePickerThemeData(
      headerBackgroundColor: AppThemeColors.darkPrimaryColor,
      headerForegroundColor: AppThemeColors.whiteColor,
      backgroundColor: AppThemeColors.darkSurfaceColor, // White body
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

      weekdayStyle: const TextStyle(color: AppThemeColors.lightGreyColor, fontWeight: FontWeight.bold),

      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        if (states.contains(WidgetState.disabled)) {
          return AppThemeColors.darkGreyColor.withValues(alpha: 0.3);
        }
        return AppThemeColors.darkTextColor;
      }),

      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppThemeColors.darkPrimaryColor;
        }
        return Colors.transparent;
      }),
      todayBorder: const BorderSide(color: AppThemeColors.darkPrimaryColor),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppThemeColors.darkPrimaryColor;
      }),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppThemeColors.darkTextColor;
      }),

      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: AppThemeColors.darkPrimaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: AppThemeColors.lightGreyColor),
    ),

    cardTheme: CardThemeData(
      color: AppThemeColors.darkSecondaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
    ),

    // Modern Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppThemeColors.darkSecondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppThemeColors.darkPrimaryColor, width: 1.5),
      ),
    ),

    dividerTheme: const DividerThemeData(color: AppThemeColors.darkGreyColor, thickness: 0.5),
  ),
};
