import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme getLightTextTheme() {
    return _buildTextTheme(ThemeData.light().textTheme);
  }

  static TextTheme getDarkTextTheme() {
    return _buildTextTheme(ThemeData.dark().textTheme);
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.ibmPlexSansTextTheme(base).copyWith(
      displayLarge: GoogleFonts.ibmPlexSans(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.ibmPlexSans(
        textStyle: base.displayMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.ibmPlexSans(
        textStyle: base.displaySmall,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.ibmPlexSans(
        textStyle: base.headlineLarge,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.ibmPlexSans(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.ibmPlexSans(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: GoogleFonts.ibmPlexSans(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.ibmPlexSans(
        textStyle: base.titleSmall,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(
        textStyle: base.bodyLarge,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        textStyle: base.bodyMedium,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.ibmPlexSans(
        textStyle: base.bodySmall,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.ibmPlexSans(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: GoogleFonts.ibmPlexSans(
        textStyle: base.labelMedium,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.ibmPlexSans(
        textStyle: base.labelSmall,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Use this for financial data, numbers, or code blocks.
  static TextStyle get monoTextStyle => GoogleFonts.ibmPlexMono();
}
