import 'package:flutter/material.dart';

// Approximated from web_app/src/styles.css oklch tokens.
class AppColors {
  static const background = Color(0xFFFBF8F2);
  static const foreground = Color(0xFF3A2A20);
  static const primary = Color(0xFFC2540E); // burnt-orange / terracotta
  static const primaryForeground = Color(0xFFFFFBF5);
  static const secondary = Color(0xFFF0DEC4);
  static const muted = Color(0xFFF5EDE0);
  static const mutedForeground = Color(0xFF8A7362);
  static const border = Color(0xFFE3D3B8);
  static const marketGreen = Color(0xFF3F6B3A);
  static const marketGold = Color(0xFFC9962F);
  static const marketCream = Color(0xFFF7ECD6);
  static const card = Color(0xFFFFFFFF);
  static const destructive = Color(0xFFD1435B);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      surface: AppColors.background,
      error: AppColors.destructive,
    ),
    fontFamily: 'Nunito Sans',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
