import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../core/widgets/audio_player_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/scanner_controller.dart';
import '../../profile/controllers/settings_controller.dart';

class DiagnosticResultScreen extends StatefulWidget {
  const DiagnosticResultScreen({super.key});

  @override
  State<DiagnosticResultScreen> createState() => _DiagnosticResultScreenState();
}

class _DiagnosticResultScreenState extends State<DiagnosticResultScreen> {
  bool? _wasHelpful;
  String? _actualClass;
  bool _confirmedByVet = false;
  final TextEditingController _commentController = TextEditingController();
  bool _feedbackSubmitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitFeedback(ScannerController scanner) async {
    await scanner.submitFeedback(
      wasHelpful: _wasHelpful,
      actualClass: _actualClass,
      confirmedByVet: _confirmedByVet,
      comment: _commentController.text.trim(),
    );
    setState(() {
      _feedbackSubmitted = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your feedback will help improve model accuracy.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scanner = context.watch<ScannerController>();
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;

    final record = scanner.lastResult;
    final treatment = scanner.lastTreatment;

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diagnostic Result')),
        body: const Center(child: Text('No active diagnosis found.')),
      );
    }

    final pred = record.prediction;
    final scan = record.scan;
    final diseaseCode = pred.predictedClass ?? 'healthy';
    final severity = pred.severity ?? 'mild';
    final urgency = pred.urgency ?? 'monitor';
    final isNotifiable = pred.isNotifiable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consolidated Diagnosis'),
        actions: [
          IconButton(
            tooltip: 'Toggle Urdu/English',
            icon: Icon(isUrdu ? Icons.language : Icons.translate),
            onPressed: settings.toggleLocale,
          ),
          IconButton(
            tooltip: 'Share Report',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diagnostic summary formatted and ready to share.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Notifiable Disease Blocking Emergency Banner (FR-07, Newcastle Disease)
            if (isNotifiable) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B1212) : AppColors.severeLight,
                  borderRadius: AppDimensions.borderRadiusLarge,
                  border: Border.all(color: AppColors.severe, width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_rounded, color: AppColors.severe, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NOTIFIABLE DISEASE ALERT: NEWCASTLE',
                            style: TextStyle(
                              color: AppColors.severe,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isUrdu
                              ? 'رانی کھیت انتہائی خطرناک اور متعدی بیماری ہے۔ فارم پر فوری قرنطینہ نافذ کریں اور پولٹری ڈاکٹر کو اطلاع دیں'
                              : 'Newcastle Disease is reportable by law. Quarantine the flock immediately and notify regional veterinary authorities.',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 2. Scan Header Card with Image and Primary Findings
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppImageView(
                        imagePath: scan.imagePath,
                        width: 88,
                        height: 88,
                        borderRadius: AppDimensions.borderRadiusMedium,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusBadge.forDisease(diseaseCode, isLarge: true),
                            const SizedBox(height: 8),
                            Text(
                              isUrdu
                                ? (diseaseCode == 'coccidiosis'
                                    ? 'کوکسیڈیوسس تشخیص'
                                    : diseaseCode == 'ncd'
                                        ? 'رانی کھیت کی علامات'
                                        : diseaseCode == 'salmonella'
                                            ? 'سالمونیلا کی تشخیص'
                                            : 'صحت مند پاخانہ')
                                : (diseaseCode == 'coccidiosis'
                                    ? 'Coccidiosis Detected'
                                    : diseaseCode == 'ncd'
                                        ? 'Newcastle Disease Detected'
                                        : diseaseCode == 'salmonella'
                                            ? 'Salmonella Detected'
                                            : 'Healthy Digestive Output'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scan ID: ${scan.id} | ${AppFormatters.relativeTime(scan.createdAt)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textMutedLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Metrics Row: AI Confidence, Severity & Urgency
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: 'AI Confidence',
                          value: AppFormatters.formatConfidence(pred.calibratedConfidence),
                          badgeColor: AppColors.primary,
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.borderLight),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Clinical Severity',
                          value: severity.toUpperCase(),
                          badgeColor: severity == 'severe'
                              ? AppColors.severe
                              : severity == 'moderate'
                                  ? AppColors.moderate
                                  : AppColors.healthy,
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.borderLight),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Action Urgency',
                          value: urgency.replaceAll('_', ' ').toUpperCase(),
                          badgeColor: urgency == 'vet_now'
                              ? AppColors.urgencyVetNow
                              : AppColors.urgencyTreatToday,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 3. Spoken Audio Voice Guide Simulator (Chapter 5)
            AudioPlayerWidget(
              title: isUrdu
                  ? 'سنیں: بیماری کی وضاحت اور علاج'
                  : 'Listen: Diagnostic Voice Narration',
              isUrdu: isUrdu,
              durationText: '1:15',
            ),
            const SizedBox(height: AppDimensions.space16),

            // 4. Clinical Medical Guidance & Prescriptions (FR-06, FR-07)
            if (treatment != null) ...[
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medication_liquid_outlined, color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isUrdu ? 'تجویز کردہ ادویات اور مقدار' : 'Recommended Medical Treatment',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...treatment.getMedicines(isUrdu).map((med) => _buildBulletItem(
                          icon: Icons.check_circle_outline,
                          iconColor: AppColors.primary,
                          text: med,
                        )),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.checklist_rtl_rounded, color: AppColors.secondary, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isUrdu ? 'بیمار پرندوں کی فوری دیکھ بھال' : 'Patient Care & Hydration Steps',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...treatment.getCareSteps(isUrdu).map((step) => _buildBulletItem(
                          icon: Icons.arrow_right_alt_rounded,
                          iconColor: AppColors.secondary,
                          text: step,
                        )),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.urgencyMonitor, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isUrdu ? 'بائیو سیکیورٹی اور شیڈ کی حفاظت' : 'Biosecurity & Quarantine Protocols',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...treatment.getBiosecurity(isUrdu).map((bio) => _buildBulletItem(
                          icon: Icons.sanitizer_outlined,
                          iconColor: AppColors.urgencyMonitor,
                          text: bio,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
            ],

            // 5. Explainable AI: Triage Rules Engine Panel
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_outlined, size: 22, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Explainable Clinical Advisory Rules',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'The advisory engine derived this plan through verifiable domain rules:',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pred.triageRules.map((rule) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          rule,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 6. Farmer Feedback & Veterinarian Confirmation Form (Chapter 5)
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Provide Field Feedback',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Does this diagnosis match your flock symptoms?',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(
                            Icons.thumb_up_alt_outlined,
                            color: _wasHelpful == true ? AppColors.healthy : null,
                          ),
                          label: const Text('Helpful'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _wasHelpful == true ? AppColors.healthy : AppColors.borderLight,
                              width: _wasHelpful == true ? 2 : 1,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _wasHelpful = true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(
                            Icons.thumb_down_alt_outlined,
                            color: _wasHelpful == false ? AppColors.severe : null,
                          ),
                          label: const Text('Not Helpful'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _wasHelpful == false ? AppColors.severe : AppColors.borderLight,
                              width: _wasHelpful == false ? 2 : 1,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _wasHelpful = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Confirmed by Licensed Poultry Veterinarian',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    value: _confirmedByVet,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _confirmedByVet = val ?? false;
                      });
                    },
                  ),
                  if (_confirmedByVet) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Confirmed Disease by Vet',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      initialValue: _actualClass ?? diseaseCode,
                      items: const [
                        DropdownMenuItem(value: 'coccidiosis', child: Text('Coccidiosis')),
                        DropdownMenuItem(value: 'ncd', child: Text('Newcastle Disease')),
                        DropdownMenuItem(value: 'salmonella', child: Text('Salmonella')),
                        DropdownMenuItem(value: 'healthy', child: Text('Healthy')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _actualClass = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add clinical notes, medicine used, or bird response...',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: _feedbackSubmitted ? 'Feedback Recorded' : 'Submit Feedback',
                    variant: ButtonVariant.outlined,
                    onPressed: _feedbackSubmitted ? null : () => _submitFeedback(scanner),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Thumb Zone Action Buttons (FR-13)
            CustomButton(
              text: 'Scan Another Specimen',
              icon: Icons.camera_alt_outlined,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
    );
  }

  static Widget _buildMetricTile({
    required String label,
    required String value,
    required Color badgeColor,
  }) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: badgeColor,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textMutedLight,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  static Widget _buildBulletItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
