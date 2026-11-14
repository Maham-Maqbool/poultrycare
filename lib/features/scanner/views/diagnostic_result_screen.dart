import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/vet_call_helper.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../core/widgets/audio_player_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/diagnostic_record.dart';
import '../../../data/models/treatment_model.dart';
import '../../../data/repositories/disease_repository.dart';
import '../../../data/repositories/diagnostic_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/disease_cause_service.dart';
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
  List<DiagnosticRecord> _allShedScans = [];
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

    List<DiagnosticRecord> allScans = [];
    try {
      allScans = await diagRepo.getAllRecords();
    } catch (e) {
      debugPrint('[DiagnosticResultScreen] Scans history lookup note: $e');
    }

    if (record == null && allScans.isNotEmpty) {
      record = allScans.first;
    }

    TreatmentModel? treatment;
    if (record != null) {
      try {
        final disease = record.prediction.predictedClass ?? 'healthy';
        final severity = record.prediction.severity ?? 'mild';
        if (disease != 'healthy') {
          treatment = await diseaseRepo.getTreatment(disease, severity);
        }
      } catch (e) {
        debugPrint('[DiagnosticResultScreen] Treatment lookup safely caught: $e');
        treatment = null;
      }
    }

    if (mounted) {
      setState(() {
        _resolvedRecord = record;
        _resolvedTreatment = treatment;
        _allShedScans = allScans;
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

  /// Launches phone dialer with the farmer's saved Veterinary Expert.
  Future<void> _callVeterinaryExpert(BuildContext context) async {
    await VetCallHelper.dialVet(context);
  }

  String _formatFriendlyScanId(String rawId, bool isUrdu) {
    return AppFormatters.formatScanId(rawId, isUrdu: isUrdu);
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
    final diseaseCode = (pred.predictedClass ?? 'healthy').toLowerCase().trim();
    final rawSeverity = (pred.severity ?? 'mild').toLowerCase().trim();
    final severity = (rawSeverity == 'healthy') ? 'mild' : rawSeverity;
    final rawUrgency = (pred.urgency ?? '').toLowerCase().replaceAll(' ', '_').trim();
    final urgency = (diseaseCode == 'healthy')
        ? 'monitor'
        : ((diseaseCode == 'newcastle' || severity == 'severe' || rawUrgency == 'vet_now' || rawUrgency.contains('vet'))
            ? 'vet_now'
            : (rawUrgency == 'vet_soon' ? 'vet_soon' : 'treat_today'));
    final isNotifiable = pred.isNotifiable || diseaseCode == 'newcastle';

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
                                  ? 'ویٹرنری ڈاکٹر کو فوراً کال کریں'
                                  : 'Call Veterinary Doctor Urgently',
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
                              _getDiseaseTitle(diseaseCode, isUrdu),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatFriendlyScanId(scan.id, isUrdu)} | ${AppFormatters.formatDate(scan.createdAt)}',
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

                  // Metrics Row: Clinical Severity & Action Urgency
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: isUrdu ? 'مرض کی شدت' : 'Clinical Severity',
                          value: isUrdu
                              ? (severity == 'severe'
                                  ? 'شدید'
                                  : (severity == 'moderate'
                                      ? 'درمیانی'
                                      : 'ہلکی'))
                              : severity.toUpperCase(),
                          badgeColor: severity == 'severe'
                              ? AppColors.severe
                              : (severity == 'moderate'
                                  ? AppColors.moderate
                                  : AppColors.mild),
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.borderLight),
                      Expanded(
                        child: _buildMetricTile(
                          label: isUrdu ? 'ضروری اقدام' : 'Action Urgency',
                          value: isUrdu
                              ? (urgency == 'vet_now'
                                  ? 'فوری ڈاکٹر'
                                  : (urgency == 'monitor' ? 'نگرانی' : 'آج ہی علاج'))
                              : (urgency == 'monitor'
                                  ? 'MONITOR'
                                  : (urgency == 'vet_now'
                                      ? 'VET NOW'
                                      : (urgency == 'vet_soon'
                                          ? 'VET SOON'
                                          : 'TREAT TODAY'))),
                          badgeColor: urgency == 'vet_now'
                              ? AppColors.urgencyVetNow
                              : (urgency == 'monitor'
                                  ? AppColors.urgencyMonitor
                                  : (urgency == 'vet_soon'
                                      ? AppColors.urgencyVetSoon
                                      : AppColors.urgencyTreatToday)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 2.3 New Result-Screen Section: "Kyun hua hoga - ishare aur check list"
            _buildCauseSection(
              context: context,
              record: record,
              scanner: scanner,
              isUrdu: isUrdu,
              isDark: isDark,
              diseaseCode: diseaseCode,
              severity: severity,
            ),

            // 2.5 Quick Link to FCR & Economics Calculator
            InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.fcrCalculator),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0C243B) : const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrdu ? 'ایف سی آر و خوراک کے نقصان کا حساب لگائیں' : 'Calculate Flock FCR & Feed Efficiency Loss',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0284C7)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isUrdu
                                ? 'دیکھیں کہ اس مرض سے آپ کی خوراک کا کتنا مالی نقصان ہو رہا ہے'
                                : 'See how this gut condition impairs feed conversion and farm profits',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF0284C7)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 3. Spoken Audio Voice Guide Simulator
            AudioPlayerWidget(
              title: isUrdu
                  ? 'سنیں: بیماری کی صوتی وضاحت اور علاج'
                  : 'Diagnostic Voice Guide',
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

            // 4. Clinical Medical Guidance & Official Veterinary Prescription (Rx)
            if (diseaseCode == 'healthy') ...[
              AppCard(
                padding: const EdgeInsets.all(18),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: BorderSide(color: AppColors.healthy.withValues(alpha: 0.4)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.healthy, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrdu ? 'کسی دوا کی ضرورت نہیں ہے' : 'No Medication Needed',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.healthy),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isUrdu
                                ? 'پرندے صحت مند ہیں۔ روزانہ معمول کی نگرانی، متوازن خوراک اور پینے کا صاف پانی جاری رکھیں۔'
                                : 'Flock is healthy. Continue routine daily monitoring, balanced feeding, and clean water sanitation.',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
            ] else if (treatment != null) ...[
              AppCard(
                padding: const EdgeInsets.all(18),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Official Veterinary Prescription Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '\u211e',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isUrdu ? 'ویٹرنری طبی نسخہ و طریقہ علاج' : 'Official Veterinary Prescription',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainerLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isUrdu ? 'منظور شدہ فارمولا' : 'Clinical Rx',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isUrdu
                                    ? 'پرندوں کا تفصیلی شیڈول، ادویات کی مقدار اور طریقہ استعمال'
                                    : 'Avian medication schedule, dosage protocols & duration',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // SECTION A: Structured Medication Cards
                    Row(
                      children: [
                        const Icon(Icons.medication_liquid_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isUrdu ? 'تجویز کردہ ادویات اور مقدار (Medications)' : 'Prescribed Medications & Dosages',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...treatment.getMedicines(isUrdu).asMap().entries.map((entry) {
                      return _buildPrescriptionCard(
                        index: entry.key,
                        rawMed: entry.value,
                        isUrdu: isUrdu,
                        isDark: isDark,
                      );
                    }),
                    const SizedBox(height: 8),

                    // SECTION B: Mandatory Withdrawal Period Alert
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF382305) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isUrdu ? 'لازمی ویٹرنری احتیاط: ادویات کا اخراجی وقفہ (Withdrawal Period)' : 'Mandatory Veterinary Safety: Withdrawal Period',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.secondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getWithdrawalText(diseaseCode, isUrdu),
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 28),

                    // SECTION C: Supportive Patient Care & Hydration Steps
                    Row(
                      children: [
                        const Icon(Icons.checklist_rtl_rounded, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isUrdu ? 'بیمار پرندوں کی نگہداشت و ہائیڈریشن' : 'Patient Care & Hydration Protocol',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...treatment.getCareSteps(isUrdu).asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 13, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 28),

                    // SECTION D: Biosecurity & Shed Quarantine Protocols
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.urgencyMonitor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isUrdu ? 'شیڈ کی بائیو سیکیورٹی اور قرنطینہ' : 'Biosecurity & Quarantine Protocols',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...treatment.getBiosecurity(isUrdu).map((bio) => _buildBulletItem(
                          icon: Icons.sanitizer_outlined,
                          iconColor: AppColors.urgencyMonitor,
                          text: bio,
                        )),
                    const SizedBox(height: 12),

                    // Copy Prescription Action
                    OutlinedButton.icon(
                      onPressed: () {
                        final meds = treatment.getMedicines(isUrdu).join('\n\u2022 ');
                        final steps = treatment.getCareSteps(isUrdu).join('\n\u2022 ');
                        final summary = isUrdu
                            ? 'طبی نسخہ (${diseaseCode.toUpperCase()}):\nادویات:\n\u2022 $meds\n\nنگہداشت:\n\u2022 $steps'
                            : 'Veterinary Prescription (${diseaseCode.toUpperCase()}):\nMedications:\n\u2022 $meds\n\nCare Steps:\n\u2022 $steps';
                        Clipboard.setData(ClipboardData(text: summary));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isUrdu ? 'طبی نسخہ کاپی ہو گیا ہے' : 'Prescription copied to clipboard',
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: Text(isUrdu ? 'نسخہ کاپی کریں (فارم مینیجر کو بھیجیں)' : 'Copy Prescription Details'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
            ] else ...[
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.moderate, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isUrdu
                            ? 'اس مرض اور شدت کا مخصوص نسخہ فی الحال دستیاب نہیں ہے۔ براہ کرم ویٹرنری ڈاکٹر سے رجوع کریں۔'
                            : 'Treatment protocol not available for this tier. Consult your veterinarian for tailored dosage.',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
            ],

            // 5. Clinical Triage Evaluation & Flock Vital Signals
            AppCard(
              padding: const EdgeInsets.all(18),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: BorderSide(
                color: severity == 'severe'
                    ? AppColors.severe.withValues(alpha: 0.4)
                    : severity == 'moderate'
                        ? AppColors.moderate.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (severity == 'severe' ? AppColors.severe : AppColors.primary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.monitor_heart_rounded,
                          color: severity == 'severe' ? AppColors.severe : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrdu ? 'فلاک وائٹلز و کلینیکل ٹریج' : 'Clinical Flock Vitals & Triage',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                            ),
                            Text(
                              isUrdu
                                  ? 'بیٹھ کی تصویر اور پرندوں کی 3 اہم علامات کی بنیاد پر'
                                  : 'Based on the specimen photo and 3 flock signs',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textMutedLight),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (severity == 'severe'
                                  ? AppColors.severe
                                  : (severity == 'moderate' ? AppColors.moderate : AppColors.healthy))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isUrdu
                              ? (severity == 'severe' ? 'شدید الرٹ' : (severity == 'moderate' ? 'نگرانی طلب' : 'مستحکم وائٹلز'))
                              : (severity == 'severe' ? 'Urgent Alert' : (severity == 'moderate' ? 'Moderate Risk' : 'Stable Vitals')),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: severity == 'severe'
                                ? AppColors.severe
                                : (severity == 'moderate' ? AppColors.moderate : AppColors.healthy),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // 3-Tile Flock Vitals Grid
                  Builder(
                    builder: (context) {
                      final signals = pred.flockSignals ?? <String, dynamic>{};
                      final lethargy = (signals['lethargy'] ?? 'None').toString();
                      final intakeDrop = (signals['intakeDrop'] ?? 'Normal').toString();
                      final suddenMortality = (signals['suddenMortality'] ?? 'None in 24h').toString();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTriageVitalTile(
                                  label: isUrdu ? 'سستی و کاہلی' : 'Lethargy',
                                  value: lethargy,
                                  icon: Icons.hotel_class_outlined,
                                  isWarning: lethargy.contains('10%'),
                                  isUrdu: isUrdu,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTriageVitalTile(
                                  label: isUrdu ? 'خوراک کمی' : 'Feed Intake',
                                  value: intakeDrop,
                                  icon: Icons.restaurant_outlined,
                                  isWarning: intakeDrop.contains('Reduced') || intakeDrop.contains('Severely'),
                                  isUrdu: isUrdu,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTriageVitalTile(
                                  label: isUrdu ? 'اموات (24h)' : '24h Mortality',
                                  value: suddenMortality,
                                  icon: Icons.heart_broken_outlined,
                                  isWarning: suddenMortality.contains('Multiple') || suddenMortality.contains('1 to 2'),
                                  isUrdu: isUrdu,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Explainable Clinical Triage Deduction Banner
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  severity == 'severe' ? Icons.error_outline_rounded : Icons.info_outline_rounded,
                                  size: 18,
                                  color: severity == 'severe' ? AppColors.severe : AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getTriageExplanation(diseaseCode, severity, signals, isUrdu),
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      initialValue: _normalizeDropdownValue(_actualClass ?? diseaseCode),
                      items: [
                        DropdownMenuItem(
                          value: 'coccidiosis',
                          child: Text(isUrdu ? 'کوکسیڈیوسس (Coccidiosis)' : 'Coccidiosis'),
                        ),
                        DropdownMenuItem(
                          value: 'newcastle',
                          child: Text(isUrdu ? 'رانی کھیت کی بیماری (Newcastle)' : 'Newcastle Disease'),
                        ),
                        DropdownMenuItem(
                          value: 'salmonella',
                          child: Text(isUrdu ? 'سالمونیلا (Salmonella)' : 'Salmonella'),
                        ),
                        DropdownMenuItem(
                          value: 'healthy',
                          child: Text(isUrdu ? 'صحت مند پرندہ (Healthy)' : 'Healthy Digestion'),
                        ),
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
                  ? 'ویٹرنری ڈاکٹر کو کال کریں'
                  : 'Call Veterinary Expert',
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

  static Map<String, String> _parseMedicationDetails(String raw, bool isUrdu) {
    String name = raw.trim();
    String dosage = isUrdu ? 'حسبِ ہدایت ویٹرنری ڈاکٹر' : 'As directed by poultry veterinarian';
    String duration = isUrdu ? '3 سے 5 دن' : '3 to 5 Days';
    String route = isUrdu ? 'پینے کا پانی' : 'Drinking Water';

    if (raw.contains('(') && raw.contains(')')) {
      final startIndex = raw.indexOf('(');
      final endIndex = raw.lastIndexOf(')');
      name = raw.substring(0, startIndex).trim();
      dosage = raw.substring(startIndex + 1, endIndex).trim();
    }

    final lower = raw.toLowerCase();
    if (lower.contains('water') || raw.contains('پانی') || lower.contains('powder') || raw.contains('پاؤڈر') || lower.contains('ml') || raw.contains('ملی')) {
      route = isUrdu ? 'پینے کا پانی' : 'Drinking Water';
    } else if (lower.contains('feed') || raw.contains('خوراک') || raw.contains('دانہ')) {
      route = isUrdu ? 'خوراک میں شامل' : 'Feed Mix';
    } else if (lower.contains('vitamin') || raw.contains('وٹامن') || lower.contains('electrolyte') || raw.contains('الیکٹرولائٹ') || lower.contains('probiotic') || raw.contains('پروبائیوٹک')) {
      route = isUrdu ? 'امدادی ٹانک' : 'Supportive Tonic';
    }

    if (dosage.contains('5') || dosage.contains('۵')) {
      duration = isUrdu ? '5 دن لگاتار' : '5 Days Continuous';
    } else if (dosage.contains('2') || dosage.contains('۲')) {
      duration = isUrdu ? '2 دن لگاتار' : '2 Days Continuous';
    } else if (dosage.contains('3-5') || dosage.contains('3 سے 5')) {
      duration = isUrdu ? '3 سے 5 دن' : '3 to 5 Days';
    }

    return {
      'name': name,
      'dosage': dosage,
      'duration': duration,
      'route': route,
    };
  }

  static Widget _buildPrescriptionCard({
    required int index,
    required String rawMed,
    required bool isUrdu,
    required bool isDark,
  }) {
    final parsed = _parseMedicationDetails(rawMed, isUrdu);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Rx #${index + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.water_drop_outlined, size: 12, color: Color(0xFF0284C7)),
                        const SizedBox(width: 4),
                        Text(
                          parsed['route'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                parsed['name'] ?? rawMed,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.science_outlined, size: 15, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${isUrdu ? "مقدار و طریقہ: " : "Dosage: "}${parsed["dosage"]}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 15, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          '${isUrdu ? "تجویز کردہ دورانیہ: " : "Duration: "}${parsed["duration"]}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _getWithdrawalText(String diseaseCode, bool isUrdu) {
    switch (diseaseCode) {
      case 'coccidiosis':
        return isUrdu
            ? 'کوکسیڈیوسس ادویات (Amprolium / Toltrazuril) کے استعمال کے دوران اور آخری خوراک کے بعد کم از کم 5 سے 7 دن تک پرندوں کو گوشت کے لیے ذبح یا مارکیٹ میں فروخت نہ کریں تاکہ کیمیائی اثرات ختم ہو سکیں۔'
            : 'Do not slaughter or sell broilers for meat within 5 to 7 days after the final dose of anticoccidial medication to ensure chemical residues are completely cleared.';
      case 'ncd':
      case 'newcastle':
        return isUrdu
            ? 'رانی کھیت ایک سنگین وائرل انفیکشن ہے۔ متاثرہ شیڈ کو کم از کم 21 دن تک مکمل قرنطینہ میں رکھیں اور پرندوں یا کھاد کی منتقلی سختی سے روکیں۔'
            : 'Newcastle is a high-consequence viral infection. Strictly quarantine the shed for 21 days. Do not transport live birds, carcasses, or litter.';
      case 'salmonella':
        return isUrdu
            ? 'اینٹی بائیوٹک تھراپی کے بعد کم از کم 7 سے 10 دن کا اخراجی وقفہ لازمی ہے۔ اس دوران حاصل کردہ انڈے یا گوشت انسانی خوراک کے لیے فروخت نہ کریں۔'
            : 'Observe a mandatory 7 to 10 day withdrawal period for meat and eggs following antibiotic therapy before selling for human consumption.';
      default:
        return isUrdu
            ? 'پرندے صحت مند ہیں، کسی قسم کی دوا یا اینٹی بائیوٹک کے استعمال کی ضرورت نہیں ہے۔ شیڈ کی عمومی صفائی برقرار رکھیں۔'
            : 'Flock demonstrates healthy digestive vitals. Zero pharmaceutical withdrawal restrictions apply.';
    }
  }

  static String _getDiseaseTitle(String rawCode, bool isUrdu) {
    final code = rawCode.toLowerCase().trim();
    if (code.contains('newcastle') || code == 'ncd') {
      return isUrdu ? 'رانی کھیت کی علامات (Newcastle)' : 'Newcastle Disease Detected';
    }
    if (code.contains('coccidiosis')) {
      return isUrdu ? 'کوکسیڈیوسس کی تشخیص (Coccidiosis)' : 'Coccidiosis Detected';
    }
    if (code.contains('salmonella')) {
      return isUrdu ? 'سالمونیلا کی تشخیص (Salmonella)' : 'Salmonella Detected';
    }
    return isUrdu ? 'صحت مند پرندہ (Healthy)' : 'Healthy Digestive Output';
  }

  static String _normalizeDropdownValue(String? raw) {
    if (raw == null) return 'healthy';
    final lower = raw.toLowerCase().trim();
    if (lower.contains('newcastle') || lower == 'ncd') return 'newcastle';
    if (lower.contains('salmonella')) return 'salmonella';
    if (lower.contains('coccidiosis')) return 'coccidiosis';
    return 'healthy';
  }

  static String _translateTriageValue(String val, bool isUrdu) {
    if (!isUrdu) return val;
    switch (val) {
      case 'None':
        return 'کوئی نہیں';
      case 'Under 10% of birds':
        return '10 فیصد سے کم';
      case 'Over 10% of birds':
        return '10 فیصد سے زیادہ';
      case 'Normal':
        return 'معمول کے مطابق';
      case 'Reduced consumption':
        return 'کچھ کمی آئی ہے';
      case 'Severely dropped':
        return 'شدید کمی آئی ہے';
      case 'None in 24h':
        return 'کوئی موت نہیں';
      case '1 to 2 birds':
        return '1 یا 2 پرندے';
      case 'Multiple birds died':
        return 'کئی پرندے مرے';
      default:
        return val;
    }
  }

  static Widget _buildTriageVitalTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isWarning,
    required bool isUrdu,
    required bool isDark,
  }) {
    final statusColor = isWarning ? AppColors.severe : AppColors.healthy;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWarning
              ? statusColor.withValues(alpha: 0.4)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMutedLight),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _translateTriageValue(value, isUrdu),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCauseSection({
    required BuildContext context,
    required DiagnosticRecord record,
    required ScannerController scanner,
    required bool isUrdu,
    required bool isDark,
    required String diseaseCode,
    required String severity,
  }) {
    final pred = record.prediction;
    final scan = record.scan;

    final wateryRatio = (pred.flockSignals?['wateryRatio'] as num?)?.toDouble() ??
        scanner.clinicalRatios?.wateryRatio;
    final bloodRatio = (pred.flockSignals?['bloodRatio'] as num?)?.toDouble() ??
        scanner.clinicalRatios?.bloodRatio;

    final causeEval = DiseaseCauseService.evaluate(
      diseaseCode: diseaseCode,
      currentSeverity: severity,
      wateryRatio: wateryRatio,
      bloodRatio: bloodRatio,
      scanDate: scan.createdAt,
      flockId: scan.flockId,
      currentScanId: scan.id,
      shedScans: _allShedScans,
    );

    if (!causeEval.shouldShow) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: BorderSide(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            width: 1.2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Color(0xFFD97706),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUrdu
                              ? 'کیوں ہوا ہوگا - اشارے اور چیک لسٹ'
                              : 'Why it may have happened - signs and checklist',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isUrdu
                              ? 'ممکنہ اشارے اور احتیاطی چیک لسٹ (پہلے یہ چیک کریں):'
                              : 'Observable signs and checklist (what to check first):',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Dynamic Observations (Photo ratios, season, shed history)
              if (causeEval.hasObservations) ...[
                const SizedBox(height: 14),
                ...causeEval.dynamicObservations.map((obs) {
                  final isUrgent = obs.isUrgent;
                  final bgColor = isUrgent
                      ? (isDark
                          ? const Color(0xFF7F1D1D).withValues(alpha: 0.25)
                          : const Color(0xFFFEF2F2))
                      : (isDark
                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                          : const Color(0xFFEFF6FF));
                  final borderColor = isUrgent
                      ? AppColors.severe.withValues(alpha: 0.3)
                      : const Color(0xFF3B82F6).withValues(alpha: 0.3);
                  final iconColor = isUrgent ? AppColors.severe : const Color(0xFF2563EB);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isUrgent ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                          size: 18,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            obs.getText(isUrdu),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isUrgent ? FontWeight.w700 : FontWeight.w500,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // Static Checklist ("pehle ye check karo")
              if (causeEval.hasChecklist) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_add_check_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        isUrdu ? 'پہلے یہ اہم نکات چیک کریں:' : 'Check these points first:',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ...causeEval.checklistItems.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$idx',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.getText(isUrdu),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimaryLight,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space16),
      ],
    );
  }

  static String _getTriageExplanation(
    String diseaseCode,
    String severity,
    Map<String, dynamic> signals,
    bool isUrdu,
  ) {
    final mortality = (signals['suddenMortality'] ?? '').toString();
    final intake = (signals['intakeDrop'] ?? '').toString();
    final lethargy = (signals['lethargy'] ?? '').toString();

    if (mortality.contains('Multiple') || mortality.contains('1 to 2')) {
      return isUrdu
          ? 'گزشتہ 24 گھنٹوں میں اموات کی نشاندہی ہوئی۔ شدت شدید (Severe) ہے۔ براہ کرم فوراً ویٹرنری ڈاکٹر سے رابطہ کریں۔'
          : 'Sudden mortality detected within 24 hours. Severity is Severe. Please consult a veterinarian immediately.';
    }

    if (intake.contains('Severely') || lethargy.contains('Over 10%')) {
      return isUrdu
          ? 'خوراک میں 30 فیصد سے زائد کمی اور فلاک میں سستی بیماری کی علامت ہے۔'
          : 'Severe feed intake drop and flock lethargy confirm illness. Severity is Moderate.';
    }

    if (diseaseCode == 'newcastle' || diseaseCode == 'ncd') {
      return isUrdu
          ? 'رانی کھیت ایک متعدی بیماری ہے۔ براہ کرم فلاک کو قرنطینہ میں رکھیں۔'
          : 'Highly contagious Newcastle disease detected. Please quarantine the flock.';
    }

    return isUrdu
        ? 'فلاک کے وائٹلز تسلی بخش ہیں۔ کوئی غیر معمولی اموات یا شدید سستی نہیں پائی گئی۔'
        : 'Flock vital signals are stable with normal feed intake and zero unexplained mortality.';
  }
}
