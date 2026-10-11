import 'package:flutter/material.dart';

/// AppColors encapsulates the design palette for PoultryCare.
/// Designed for high outdoor legibility in rural poultry farming contexts.
class AppColors {
  // Brand Primary: Deep Emerald
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryMedium = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryContainerLight = Color(0xFFE8F5E9);
  static const Color primaryContainerDark = Color(0xFF132D18);

  // Secondary Accent: Warm Harvest Amber
  static const Color secondary = Color(0xFFD97706);
  static const Color secondaryLight = Color(0xFFFBBF24);
  static const Color secondaryContainerLight = Color(0xFFFEF3C7);
  static const Color secondaryContainerDark = Color(0xFF382305);

  // Neutral Background & Surface: Light
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Neutral Background & Surface: Dark
  static const Color backgroundDark = Color(0xFF0A0F1D);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF64748B);

  // Semantic Diagnostic & Clinical Severity
  static const Color healthy = Color(0xFF16A34A);
  static const Color healthyLight = Color(0xFFDCFCE7);
  static const Color mild = Color(0xFFEAB308);
  static const Color mildLight = Color(0xFFFEF9C3);
  static const Color moderate = Color(0xFFEA580C);
  static const Color moderateLight = Color(0xFFFFEDD5);
  static const Color severe = Color(0xFFDC2626);
  static const Color severeLight = Color(0xFFFEE2E2);

  // Urgency Action Colors
  static const Color urgencyMonitor = Color(0xFF0D9488);
  static const Color urgencyTreatToday = Color(0xFFD97706);
  static const Color urgencyVetSoon = Color(0xFFEA580C);
  static const Color urgencyVetNow = Color(0xFFB91C1C);

  // State Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);
}
