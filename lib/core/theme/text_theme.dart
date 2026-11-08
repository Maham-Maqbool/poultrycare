import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// AppTypography configures Google Fonts Plus Jakarta Sans type scale
/// with generous line heights and strong outdoor contrast.
class AppTypography {
  static TextTheme createTextTheme({required bool isDark}) {
    final baseColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    try {
      return TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: baseColor,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: baseColor,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: baseColor,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: baseColor,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          color: baseColor,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: baseColor,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: baseColor,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          color: secondaryColor,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: baseColor,
          fontSize: 16.0,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: secondaryColor,
          fontSize: 14.0,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          fontSize: 12.0,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          color: baseColor,
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
      );
    } catch (_) {
      // Fallback if font downloading is unavailable
      return TextTheme(
        headlineMedium: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w600,
          fontSize: 20.0,
        ),
        titleMedium: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
        ),
        bodyLarge: TextStyle(
          color: baseColor,
          fontSize: 16.0,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: secondaryColor,
          fontSize: 14.0,
        ),
      );
    }
  }
}
