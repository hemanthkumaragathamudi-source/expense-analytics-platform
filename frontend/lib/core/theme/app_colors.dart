import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color black = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // Grays (Light to Dark)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Semantic Colors
  static const Color errorLight = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFF87171);
  static const Color successLight = Color(0xFF16A34A);
  static const Color successDark = Color(0xFF4ADE80);

  // Light Theme Specific
  static const Color backgroundLight = gray50;
  static const Color surfaceLight = white;
  static const Color textPrimaryLight = gray900;
  static const Color textSecondaryLight = gray500;
  static const Color borderLight = gray200;
  static const Color primaryLight = black;
  static const Color onPrimaryLight = white;

  // Dark Theme Specific
  static const Color backgroundDark = gray900;
  static const Color surfaceDark = gray800;
  static const Color textPrimaryDark = gray50;
  static const Color textSecondaryDark = gray400;
  static const Color borderDark = gray700;
  static const Color primaryDark = white;
  static const Color onPrimaryDark = black;
}
