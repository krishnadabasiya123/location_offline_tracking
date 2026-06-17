import 'package:flutter/material.dart';

class AppThemeColors {
  // ==========================================
  // LIGHT THEME COLORS (From Screenshots 12-20)
  // ==========================================
  /// Application main Blue: #2F88EB
  static const Color lightPrimaryColor = Color(0xff2F88EB);

  /// Scaffold Background (Light Grey/Cool White): #F2F1F6
  static const Color lightSurfaceColor = Color.fromARGB(255, 244, 244, 250);

  /// Card/Container color (Pure White): #FFFFFF
  static const Color lightSecondaryColor = Color(0xFFFFFFFF);

  /// Primary Text color: #212121
  static const Color lightTextColor = Color(0xFF212121);
  // black Text color: #000000
  static const Color lightBlackTextColor = Color(0xFF000000);
  static const Color lightGreyColor = Color(0xFF8B8B8B);

  // ==========================================
  // DARK THEME COLORS (From Screenshots 1-11)
  // ==========================================
  /// Application Primary Blue (Electric Blue): #3B82F6
  static const Color darkPrimaryColor = Color(0xff3B82F6);

  /// Scaffold Background (Deep Navy/Black): #0B121A
  static const Color darkSurfaceColor = Color.fromARGB(255, 11, 17, 24);

  /// Card/Container color (Slate Navy): #1A222C
  static const Color darkSecondaryColor = Color(0xFF192633);

  /// Primary Text color: #FFFFFF
  static const Color darkTextColor = Color(0xFFFFFFFF);
  // black Text color: #000000
  static const Color darkBlackTextColor = Color(0xFF000000);

  static const Color darkGreyColor = Color(0xff64748B);

  // ==========================================
  // STATUS COLORS (From History Screen)
  // ==========================================
  static const Color errorColor = Color(0xFFEF4444);
  static const Color whiteColor = Colors.white;
  static const Color redColor = Color(0xffEF4444);
  static const Color greenColor = Color(0xff10B981); // Delivered Status
  static const Color amberColor = Color(0xffF59E0B); // Processing Status

  // Status mappings based on your design
  static const Color pendingColor = Color(0xff3B82F6);
  static const Color deliveredColor = Color(0xff10B981);
  static const Color processingColor = Color(0xffF59E0B);
  static const Color cancelledColor = Color(0xff64748B);

  // ==========================================
  // GRADIENT COLORS (For Splash & Main Buttons)
  // ==========================================
  static const Color linearGradientPrimary = Color(0xff2F88EB);
  static const Color linearGradientSecondary = Color(0xff1E40AF);

  // ==========================================
  // TEXT COLORS (For Text)
  // ==========================================
  
}
