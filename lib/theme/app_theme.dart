import 'package:flutter/material.dart';

class AppColors {
  // Aurora Pulse — коралл + фиолет + тёплый фон
  static const Color primary = Color(0xFFFF4757);
  static const Color primaryDark = Color(0xFFE8364A);
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentViolet = Color(0xFF9333EA);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentMint = Color(0xFF2DD4BF);

  static const Color background = Color(0xFFFFFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFFFF1F2);

  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF78716C);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color divider = Color(0xFFFECDD3);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFBBF24);

  static const Color mapOverlay = Color(0x991C1917);
  static const Color routeLine = Color(0xFF7C3AED);
  static const Color pickupMarker = Color(0xFF10B981);
  static const Color dropoffMarker = Color(0xFFFF4757);
  static const Color driverMarker = Color(0xFF9333EA);
  static const Color userLocation = Color(0xFFFF4757);

  static const Color darkBg = Color(0xFF1C1917);
  static const Color darkSurface = Color(0xFF292524);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFF7C3AED)],
    begin: Alignment.centerLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradientVertical = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFDB2777), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF1C1917), Color(0xFF581C87), Color(0xFF9F1239)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x26FF4757), Color(0x267C3AED)],
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
        tertiary: AppColors.accentMint,
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
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
    );
  }
}
