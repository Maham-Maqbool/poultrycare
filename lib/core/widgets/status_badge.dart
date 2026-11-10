import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../utils/formatters.dart';

/// StatusBadge renders colored pill badges for disease classes,
/// clinical severity rankings, and urgency flags.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.isLarge = false,
  });

  // Factory constructor for Disease Classes
  factory StatusBadge.forDisease(String code, {bool isLarge = false}) {
    switch (code.toLowerCase()) {
      case 'coccidiosis':
        return StatusBadge(
          label: 'Coccidiosis',
          backgroundColor: AppColors.moderateLight,
          textColor: AppColors.moderate,
          icon: Icons.biotech_outlined,
          isLarge: isLarge,
        );
      case 'ncd':
      case 'newcastle':
      case 'newcastle disease':
        return StatusBadge(
          label: 'Newcastle Disease',
          backgroundColor: AppColors.severeLight,
          textColor: AppColors.severe,
          icon: Icons.warning_amber_rounded,
          isLarge: isLarge,
        );
      case 'salmonella':
        return StatusBadge(
          label: 'Salmonella',
          backgroundColor: AppColors.mildLight,
          textColor: const Color(0xFFB45309),
          icon: Icons.coronavirus_outlined,
          isLarge: isLarge,
        );
      case 'healthy':
      default:
        return StatusBadge(
          label: 'Healthy',
          backgroundColor: AppColors.healthyLight,
          textColor: AppColors.healthy,
          icon: Icons.check_circle_outline,
          isLarge: isLarge,
        );
    }
  }

  // Factory constructor for Severity Levels
  factory StatusBadge.forSeverity(String? severity, {bool isLarge = false}) {
    final s = (severity ?? 'healthy').toLowerCase();
    switch (s) {
      case 'mild':
        return StatusBadge(
          label: 'Mild Severity',
          backgroundColor: AppColors.mildLight,
          textColor: const Color(0xFFB45309),
          icon: Icons.info_outline,
          isLarge: isLarge,
        );
      case 'moderate':
        return StatusBadge(
          label: 'Moderate Severity',
          backgroundColor: AppColors.moderateLight,
          textColor: AppColors.moderate,
          icon: Icons.warning_amber_outlined,
          isLarge: isLarge,
        );
      case 'severe':
        return StatusBadge(
          label: 'Severe Risk',
          backgroundColor: AppColors.severeLight,
          textColor: AppColors.severe,
          icon: Icons.error_outline,
          isLarge: isLarge,
        );
      case 'healthy':
      default:
        return StatusBadge(
          label: 'Normal / Healthy',
          backgroundColor: AppColors.healthyLight,
          textColor: AppColors.healthy,
          icon: Icons.sentiment_satisfied_alt_outlined,
          isLarge: isLarge,
        );
    }
  }

  // Factory constructor for Urgency Levels
  factory StatusBadge.forUrgency(String? urgency, {bool isLarge = false}) {
    final u = (urgency ?? 'monitor').toLowerCase();
    switch (u) {
      case 'vet_now':
        return StatusBadge(
          label: 'Urgent Vet Required',
          backgroundColor: const Color(0xFFFEE2E2),
          textColor: AppColors.urgencyVetNow,
          icon: Icons.emergency_outlined,
          isLarge: isLarge,
        );
      case 'vet_soon':
        return StatusBadge(
          label: 'Consult Vet Soon',
          backgroundColor: const Color(0xFFFFEDD5),
          textColor: AppColors.urgencyVetSoon,
          icon: Icons.local_hospital_outlined,
          isLarge: isLarge,
        );
      case 'treat_today':
        return StatusBadge(
          label: 'Treat Today',
          backgroundColor: const Color(0xFFFEF3C7),
          textColor: AppColors.urgencyTreatToday,
          icon: Icons.medication_outlined,
          isLarge: isLarge,
        );
      case 'monitor':
      default:
        return StatusBadge(
          label: 'Monitor Daily',
          backgroundColor: const Color(0xFFCCFBF1),
          textColor: AppColors.urgencyMonitor,
          icon: Icons.visibility_outlined,
          isLarge: isLarge,
        );
    }
  }

  // Factory constructor for Certainty Levels
  factory StatusBadge.forCertainty(
    String? certainty, {
    double? confidenceScore,
    bool isUrdu = false,
    bool isLarge = false,
  }) {
    String c = (certainty ?? 'high').toLowerCase();
    if (confidenceScore != null) {
      if (confidenceScore >= 0.95) {
        c = 'high';
      } else if (confidenceScore >= 0.80) {
        c = 'moderate';
      } else {
        c = 'uncertain';
      }
    } else if (c == 'confident') {
      c = 'high';
    }

    final scoreSuffix = confidenceScore != null
        ? ': ${AppFormatters.formatConfidence(confidenceScore)}'
        : '';

    switch (c) {
      case 'cannot_tell':
        return StatusBadge(
          label: isUrdu ? 'تعین نا ممکن$scoreSuffix' : 'Cannot Determine$scoreSuffix',
          backgroundColor: const Color(0xFFF1F5F9),
          textColor: const Color(0xFF475569),
          icon: Icons.help_outline,
          isLarge: isLarge,
        );
      case 'uncertain':
        return StatusBadge(
          label: isUrdu
              ? (confidenceScore != null
                  ? 'اے آئی یقین: غیر یقینی ($scoreSuffix)'
                  : 'غیر یقینی پیش گوئی')
              : (confidenceScore != null
                  ? 'AI Confidence$scoreSuffix (Uncertain)'
                  : 'Uncertain Prediction'),
          backgroundColor: const Color(0xFFFEF9C3),
          textColor: const Color(0xFF854D0E),
          icon: Icons.question_mark_outlined,
          isLarge: isLarge,
        );
      case 'moderate':
        return StatusBadge(
          label: isUrdu
              ? 'درمیانی یقین$scoreSuffix'
              : 'AI Confidence$scoreSuffix (Moderate)',
          backgroundColor: const Color(0xFFE0F2FE),
          textColor: const Color(0xFF0369A1),
          icon: Icons.info_outline,
          isLarge: isLarge,
        );
      case 'high':
      default:
        return StatusBadge(
          label: isUrdu
              ? 'اعلیٰ یقین$scoreSuffix'
              : 'AI Confidence$scoreSuffix (High)',
          backgroundColor: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF15803D),
          icon: Icons.verified_outlined,
          isLarge: isLarge,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? AppDimensions.space12 : AppDimensions.space8,
        vertical: isLarge ? AppDimensions.space6 : AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimensions.borderRadiusCircular,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isLarge ? AppDimensions.iconMedium : AppDimensions.iconSmall,
              color: textColor,
            ),
            SizedBox(width: isLarge ? AppDimensions.space6 : AppDimensions.space4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: isLarge ? 13.0 : 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
