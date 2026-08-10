import 'package:flutter/material.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────
// SecurityIA Fem brand palette, extracted from logo:
//   Background purple  →  #6B008E
//   Mascot purple      →  #7E2FBE
//   Light crescent     →  #9B6FD6
//   Orange accent      →  #F5A323
class AppColors {
  // Primary – Brand Purple (fondo del logo)
  static const Color primary = Color(0xFF6B008E);
  static const Color primaryLight = Color(0xFF8B2FC0);
  static const Color primaryAccent = Color(0xFF9B6FD6);
  static const Color primarySurface = Color(0xFFF3E5FF);

  // Brand orange (luna/mano del logo)
  static const Color brandOrange = Color(0xFFF5A323);
  static const Color brandOrangeLight = Color(0xFFFFF0D6);

  // Emergency (rojo) – protocolo de emergencia
  static const Color emergency = Color(0xFFE53935);
  static const Color emergencyDark = Color(0xFFB71C1C);
  static const Color emergencyLight = Color(0xFFFFCDD2);

  // Status
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF5A323);   // usa orange de marca
  static const Color warningLight = Color(0xFFFFF0D6);
  static const Color info = Color(0xFF8B2FC0);
  static const Color infoLight = Color(0xFFF3E5FF);

  // Neutral
  static const Color background = Color(0xFFF7F0FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A0A2E);
  static const Color textSecondary = Color(0xFF5E4A7A);
  static const Color textHint = Color(0xFFAA90C8);
  static const Color divider = Color(0xFFE8D8F8);
  static const Color cardShadow = Color(0x186B008E);

  // Wearable
  static const Color wearableConnected = Color(0xFF8B2FC0);
  static const Color wearableDisconnected = Color(0xFF9E9E9E);

  // Stress level colors
  static const Color stressLow = Color(0xFF4CAF50);
  static const Color stressMedium = Color(0xFFF5A323);
  static const Color stressHigh = Color(0xFFE53935);
}

// ─── Theme ───────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.brandOrange,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.brandOrangeLight,
        onSecondaryContainer: AppColors.primary,
        tertiary: AppColors.primaryAccent,
        onTertiary: Colors.white,
        error: AppColors.emergency,
        onError: Colors.white,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceVariant: Color(0xFFF7F0FF),
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.divider,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEEF2F7), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.emergency),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIconColor: AppColors.textSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySurface,
        labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
