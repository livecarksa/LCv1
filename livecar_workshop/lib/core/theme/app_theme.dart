import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.arabicUI,
    colorScheme: const ColorScheme.light(
      primary: AppColors.bluePrimary,
      secondary: AppColors.orange,
      surface: AppColors.white,
      error: AppColors.red,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textDark,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.grayLight,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.blueDark,
      foregroundColor: AppColors.white,
      elevation: 0,
      titleTextStyle: AppTypography.titleSm(color: AppColors.white),
    ),
    cardTheme: const CardTheme(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grayMid),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grayMid),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bluePrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.bodyMd(color: AppColors.grayText),
    ),
  );
}
