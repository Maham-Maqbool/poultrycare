import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../core/widgets/audio_player_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/diagnostic_record.dart';
import '../../../data/models/treatment_model.dart';
import '../../../data/repositories/disease_repository.dart';
import '../../../data/repositories/diagnostic_repository.dart';
import '../controllers/scanner_controller.dart';
import '../../profile/controllers/settings_controller.dart';

class DiagnosticResultScreen extends StatefulWidget {
  final DiagnosticRecord? initialRecord;

  const DiagnosticResultScreen({super.key, this.initialRecord});

  @override
  State<DiagnosticResultScreen> createState() => _DiagnosticResultScreenState();
}

class _DiagnosticResultScreenState extends State<DiagnosticResultScreen> {
  bool? _wasHelpful;
  String? _actualClass;
  bool _confirmedByVet = false;
  final TextEditingController _commentController = TextEditingController();
  bool _feedbackSubmitted = false;

  DiagnosticRecord? _resolvedRecord;
  TreatmentModel? _resolvedTreatment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveRecordAndTreatment();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _resolveRecordAndTreatment() async {
    final scanner = context.read<ScannerController>();
    final diseaseRepo = context.read<DiseaseRepository>();
    final diagRepo = context.read<DiagnosticRepository>();

    DiagnosticRecord? record = widget.initialRecord;

    if (record == null) {
      final routeArg = ModalRoute.of(context)?.settings.arguments;
      if (routeArg is DiagnosticRecord) {
        record = routeArg;
      }
    }

    record ??= scanner.lastResult;

    if (record == null) {
      final all = await diagRepo.getAllRecords();
      if (all.isNotEmpty) {
        record = all.first;
      }
    }

    TreatmentModel? treatment;
    if (record != null) {
      final disease = record.prediction.predictedClass ?? 'healthy';
      final severity = record.prediction.severity ?? 'mild';
      treatment = await diseaseRepo.getTreatment(disease, severity);
    }

    if (mounted) {
      setState(() {
        _resolvedRecord = record;
        _resolvedTreatment = treatment;
        _isLoading = false;
      });
    }
  }

  void _submitFeedback(ScannerController scanner) async {
    if (_resolvedRecord == null) return;
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
          content: Text('Feedback successfully recorded in field logs.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  /// Launches the phone dialer with the 24/7 Poultry Veterinary Helpline.
  Future<void> _callVeterinaryExpert(BuildContext context) async {
    const phoneNumber = '+923001234567'; // 24/7 Poultry Veterinary Helpline
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Helpline available directly at: +92 300 1234567',
            ),
            backgroundColor: AppColors.severe,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scanner = context.watch<ScannerController>();
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(isUrdu ? 'تشخیصی رپورٹ' : 'Diagnostic Result')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final record = _resolvedRecord ?? scanner.lastResult;
    final treatment = _resolvedTreatment ?? scanner.lastTreatment;

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isUrdu ? 'تشخیصی رپورٹ' : 'Diagnostic Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.biotech_outlined, size: 54, color: AppColors.textMutedLight),
              const SizedBox(height: 12),
              Text(
                isUrdu ? 'کوئی فعال تشخیصی ریکارڈ دستیاب نہیں ہے' : 'No active diagnosis found.',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(isUrdu ? 'نیا اسکین شروع کریں' : 'Start Diagnostic Scan'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
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
        title: Text(isUrdu ? 'مکمل تشخیصی رپورٹ' : 'Consolidated Diagnosis'),
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
                SnackBar(
                  content: Text(isUrdu
                      ? 'تشخیصی رپورٹ شیئر کرنے کے لیے تیار ہے'
                      : 'Diagnostic summary formatted and ready to share.'),
                  duration: const Duration(seconds: 2),
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
            // 1. Notifiable Disease Blocking Emergency Banner (Newcastle Disease)
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
                          Text(
                            isUrdu
                                ? 'ہنگامی الرٹ: رانی کھیت کی خطرناک بیماری'
                                : 'NOTIFIABLE DISEASE ALERT: NEWCASTLE',
                            style: const TextStyle(
                              color: AppColors.severe,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isUrdu
                                ? 'رانی کھیت انتہائی تیز اور متعدی بیماری ہے۔ فوری طور پر بیمار پرندوں کو الگ کریں اور ڈاکٹر کو مطلع کریں۔'
                                : 'Newcastle Disease is reportable by law. Quarantine the flock immediately and notify regional veterinary authorities.',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.severe,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                            label: Text(
                              isUrdu
                                  ? 'ہیلپ لائن پر کال کریں (+92 300 1234567)'
                                  : 'Call Veterinary Emergency Hotline',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                            ),
                            onPressed: () => _callVeterinaryExpert(context),
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
                                      ? 'کوکسیڈیوسس کی تشخیص'
                                      : diseaseCode == 'ncd'
                                          ? 'رانی کھیت کی علامات'
                                          : diseaseCode == 'salmonella'
                                              ? 'سالمونیلا کی تشخیص'
                                              : 'صحت مند پرندہ')
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
                              'ID: ${scan.id} | ${AppFormatters.relativeTime(scan.createdAt)}',
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
                          label: isUrdu ? 'یقینی شرح' : 'AI Confidence',
                          value: AppFormatters.formatConfidence(pred.calibratedConfidence),
                          badgeColor: AppColors.primary,
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.borderLight),
                      Expanded(
                        child: _buildMetricTile(
                          label: isUrdu ? 'مرض کی شدت' : 'Clinical Severity',
                          value: isUrdu
                              ? (severity == 'severe'
                                  ? 'شدید'
                                  : (severity == 'moderate' ? 'درمیانی' : 'ہلکی'))
                              : severity.toUpperCase(),
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
                          label: isUrdu ? 'ضروری اقدام' : 'Action Urgency',
                          value: isUrdu
                              ? (urgency == 'vet_now' ? 'فوری ڈاکٹر' : 'آج ہی علاج')
                              : urgency.replaceAll('_', ' ').toUpperCase(),
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

            // 3. Spoken Audio Voice Guide Simulator
            AudioPlayerWidget(
              title: isUrdu
                  ? 'سنیں: بیماری کی صوتی وضاحت اور علاج'
                  : 'Listen: Diagnostic Voice Narration',
              isUrdu: isUrdu,
              durationText: '1:15',
              diseaseName: diseaseCode,
              severity: severity,
              urgency: urgency,
              confidenceScore: pred.calibratedConfidence,
              medications: treatment?.getMedicines(isUrdu) ?? [],
              careSteps: treatment?.getCareSteps(isUrdu) ?? [],
            ),
            const SizedBox(height: AppDimensions.space16),

            // 4. Clinical Medical Guidance & Prescriptions
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

            // 5. Clinical Decision Engine Rules
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rule_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu ? 'تشخیصی اصول اور فلاک سگنلز' : 'Clinical Triage Evaluation',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isUrdu
                        ? 'یہ نتیجہ تصویر کے معائنے اور پرندوں کے سگنلز کی بنیاد پر اخذ کیا گیا ہے:'
                        : 'Calibrated from on-device inference combined with flock vital signals:',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: pred.triageRules.map((rule) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

            // 6. Farmer Feedback Form
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu ? 'کسان فیڈ بیک فارم' : 'Provide Field Feedback',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUrdu
                        ? 'کیا یہ تشخیص آپ کے پرندوں کی علامات کے مطابق ہے؟'
                        : 'Does this diagnosis match your flock symptoms?',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
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
                          label: Text(isUrdu ? 'درست ہے' : 'Helpful'),
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
                          label: Text(isUrdu ? 'درست نہیں' : 'Not Helpful'),
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
                    title: Text(
                      isUrdu
                          ? 'ویٹرنری ڈاکٹر سے تصدیق شدہ'
                          : 'Confirmed by Licensed Poultry Veterinarian',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                      decoration: InputDecoration(
                        labelText: isUrdu ? 'ڈاکٹر کی تجویز کردہ بیماری' : 'Confirmed Disease by Vet',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      initialValue: _actualClass ?? diseaseCode,
                      items: [
                        DropdownMenuItem(value: 'coccidiosis', child: Text(isUrdu ? 'کوکسیڈیوسس' : 'Coccidiosis')),
                        DropdownMenuItem(value: 'ncd', child: Text(isUrdu ? 'رانی کھیت کی بیماری' : 'Newcastle Disease')),
                        DropdownMenuItem(value: 'salmonella', child: Text(isUrdu ? 'سالمونیلا' : 'Salmonella')),
                        DropdownMenuItem(value: 'healthy', child: Text(isUrdu ? 'صحت مند' : 'Healthy')),
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
                    decoration: InputDecoration(
                      hintText: isUrdu
                          ? 'پرندوں کا ردعمل، دی گئی ادویات وغیرہ...'
                          : 'Add clinical notes, medicine used, or bird response...',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: _feedbackSubmitted
                        ? (isUrdu ? 'فیڈ بیک محفوظ ہو چکا ہے' : 'Feedback Recorded')
                        : (isUrdu ? 'فیڈ بیک محفوظ کریں' : 'Submit Feedback'),
                    variant: ButtonVariant.outlined,
                    onPressed: _feedbackSubmitted ? null : () => _submitFeedback(scanner),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Emergency Vet Call Feature & Navigation Actions
            CustomButton(
              text: isUrdu
                  ? 'ویٹرنری ڈاکٹر کو کال کریں (+92 300 1234567)'
                  : 'Call Veterinary Expert (+92 300 1234567)',
              icon: Icons.phone_in_talk_rounded,
              onPressed: () => _callVeterinaryExpert(context),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: isUrdu ? 'دوسری تصویر کا اسکین کریں' : 'Scan Another Specimen',
              icon: Icons.camera_alt_outlined,
              variant: ButtonVariant.outlined,
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
