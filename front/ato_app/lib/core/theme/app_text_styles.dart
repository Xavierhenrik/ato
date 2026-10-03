import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
      );

  // Display
  static TextStyle displayLarge = _inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Headings
  static TextStyle h1 = _inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static TextStyle h2 = _inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static TextStyle h3 = _inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle h3Gold = _inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
  );

  // Body
  static TextStyle bodyLarge = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static TextStyle bodyMedium = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static TextStyle bodySmall = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Labels
  static TextStyle labelLarge = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle labelMedium = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static TextStyle labelSmall = _inter(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Accent / Gold
  static TextStyle accentLarge = _inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );
  static TextStyle accentMedium = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
  );
  static TextStyle link = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.accent,
  );

  // Logo / Brand
  static TextStyle logoTitle = _inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
    letterSpacing: 2,
  );

  // Bottom nav labels (I8 — single source of truth para BottomNavigationBar)
  static TextStyle navLabelSelected = _inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
  static TextStyle navLabelUnselected = _inter(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );
}
