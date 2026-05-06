import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String arabicUI       = 'IBMPlexArabic';
  static const String arabicHeadline = 'Alexandria';

  static const double bodyAr   = 16.0;
  static const double bodyArLg = 18.0;
  static const double caption  = 12.0;
  static const double label    = 14.0;

  static TextStyle displayLg({Color color = AppColors.textDark}) => TextStyle(
    fontFamily: arabicHeadline, fontSize: 32, fontWeight: FontWeight.w700,
    height: 1.6, color: color,
  );

  static TextStyle headlineMd({Color color = AppColors.textDark}) => TextStyle(
    fontFamily: arabicHeadline, fontSize: 24, fontWeight: FontWeight.w600,
    height: 1.6, color: color,
  );

  static TextStyle titleSm({Color color = AppColors.textDark}) => TextStyle(
    fontFamily: arabicHeadline, fontSize: 20, fontWeight: FontWeight.w600,
    height: 1.6, color: color,
  );

  static TextStyle bodyLg({Color color = AppColors.textMid}) => TextStyle(
    fontFamily: arabicUI, fontSize: bodyArLg, fontWeight: FontWeight.w400,
    height: 1.6, color: color,
  );

  static TextStyle bodyMd({Color color = AppColors.textMid}) => TextStyle(
    fontFamily: arabicUI, fontSize: bodyAr, fontWeight: FontWeight.w400,
    height: 1.6, color: color,
  );

  static TextStyle labelMd({Color color = AppColors.textDark}) => TextStyle(
    fontFamily: arabicUI, fontSize: label, fontWeight: FontWeight.w500,
    height: 1.6, color: color,
  );

  static TextStyle captionSm({Color color = AppColors.grayText}) => TextStyle(
    fontFamily: arabicUI, fontSize: caption, fontWeight: FontWeight.w400,
    height: 1.6, color: color,
  );
}
