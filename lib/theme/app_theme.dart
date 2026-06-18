import 'package:flutter/material.dart';

class AppColors {
  // Brand — cyan → indigo gradient (modern mobility)
  static const Color primary = Color(0xFF06B6D4);
  static const Color primaryDark = Color(0xFF0891B2);
  static const Color accent = Color(0xFF6366F1);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentPink = Color(0xFFEC4899);

  static const Color background = Color(0xFFF0F4FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2FF);

  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color divider = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFF43F5E);
  static const Color warning = Color(0xFFF59E0B);

  static const Color mapOverlay = Color(0x990F172A);
  static const Color routeLine = Color(0xFF6366F1);
  static const Color pickupMarker = Color(0xFF22C55E);
  static const Color dropoffMarker = Color(0xFFF43F5E);
  static const Color driverMarker = Color(0xFF8B5CF6);
  static const Color userLocation = Color(0xFF06B6D4);

  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E1B4B);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient brandGradientVertical = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [darkBg, darkSurface, Color(0xFF312E81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x1A06B6D4), Color(0x1A6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
