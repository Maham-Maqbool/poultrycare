import '../data/models/diagnostic_record.dart';

/// Represents a dynamic observation derived from photo ratios, seasonal timing,
/// or recurring shed history within local SQLite records.
class CauseObservation {
  final String textEn;
  final String textUr;
  final bool isUrgent;

  const CauseObservation({
    required this.textEn,
    required this.textUr,
    this.isUrgent = false,
  });

  String getText(bool isUrdu) => isUrdu ? textUr : textEn;
}

/// Represents an evidence-based biosecurity or clinical verification check.
class CauseChecklistItem {
  final String textEn;
  final String textUr;

  const CauseChecklistItem({
    required this.textEn,
    required this.textUr,
  });

  String getText(bool isUrdu) => isUrdu ? textUr : textEn;
}

/// Consolidated evaluation containing dynamic observations and disease-specific checklist.
class DiseaseCauseEvaluation {
  final bool shouldShow;
  final List<CauseObservation> dynamicObservations;
  final List<CauseChecklistItem> checklistItems;

  const DiseaseCauseEvaluation({
    required this.shouldShow,
    required this.dynamicObservations,
    required this.checklistItems,
  });

  bool get hasObservations => dynamicObservations.isNotEmpty;
  bool get hasChecklist => checklistItems.isNotEmpty;
}

/// DiseaseCauseService synthesizes potential causes and biosecurity checklists
/// exclusively from on-device data:
/// 1. Pre-computed photo ratios (watery consistency > 0.1676, blood ratio > 0.2239)
/// 2. Device calendar season (July to September = Monsoon in Pakistan)
/// 3. Local SQLite shed history (same flock, last 30 days)
/// 4. Established veterinary checklists (checks to investigate first)
class DiseaseCauseService {
  static const double wateryCeiling = 0.1676;
  static const double bloodCeiling = 0.2239;

  /// Evaluates signs and checklist for the diagnosed specimen.
  /// Returns shouldShow = false for Healthy specimens.
  static DiseaseCauseEvaluation evaluate({
    required String diseaseCode,
    required String currentSeverity,
    double? wateryRatio,
    double? bloodRatio,
    DateTime? scanDate,
    String? flockId,
    String? currentScanId,
    List<DiagnosticRecord>? shedScans,
  }) {
    final normDisease = _normalizeDisease(diseaseCode);

    // Rule: Show ONLY for Coccidiosis, Newcastle, Salmonella. NEVER for Healthy.
    if (normDisease == 'healthy') {
      return const DiseaseCauseEvaluation(
        shouldShow: false,
        dynamicObservations: [],
        checklistItems: [],
      );
    }

    final date = scanDate ?? DateTime.now();
    final dynamicObservations = <CauseObservation>[];

    // ==========================================
    // Input 1: Photo Ratios (from already computed ratios)
    // ==========================================
    if (wateryRatio != null && wateryRatio > wateryCeiling) {
      dynamicObservations.add(
        const CauseObservation(
          textEn: 'Droppings are very watery - check ambient heat and water consumption first.',
          textUr: 'بیٹھ بہت گیلی ہے - پہلے گرمی اور پانی کا استعمال چیک کریں۔',
        ),
      );
    }

    if (bloodRatio != null && bloodRatio > bloodCeiling) {
      dynamicObservations.add(
        const CauseObservation(
          textEn: 'Blood is high - this points to intestinal inflammation, show it to the vet.',
          textUr: 'خون زیادہ ہے - یہ انتڑیوں کی سوزش کی طرف اشارہ ہے، ڈاکٹر کو دکھائیں۔',
          isUrgent: true,
        ),
      );
    }

    // ==========================================
    // Input 2: Date / Season (Monsoon = July to September)
    // ONLY for Coccidiosis. Newcastle and Salmonella get NO season line.
    // ==========================================
    if (normDisease == 'coccidiosis') {
      final month = date.month;
      if (month >= 7 && month <= 9) {
        dynamicObservations.add(
          const CauseObservation(
            textEn: 'Rainy season is the most dangerous time for this disease - check the litter for dampness.',
            textUr: 'بارش کا موسم اس بیماری کے لیے سب سے خطرناک ہوتا ہے - لٹر کا گیلا پن چیک کریں۔',
          ),
        );
      }
    }

    // ==========================================
    // Input 3: Shed History (local SQLite, same flock/shed in last 30 days)
    // ==========================================
    if (shedScans != null && shedScans.isNotEmpty) {
      final thirtyDaysAgo = date.subtract(const Duration(days: 30));

      final matchingShedScans = shedScans.where((r) {
        if (currentScanId != null && r.scan.id == currentScanId) return false;
        if (flockId != null && flockId.isNotEmpty && r.scan.flockId != flockId) return false;
        if (r.scan.createdAt.isBefore(thirtyDaysAgo)) return false;
        if (r.scan.createdAt.isAfter(date)) return false;

        final scanDisease = _normalizeDisease(r.prediction.predictedClass ?? '');
        return scanDisease == normDisease;
      }).toList();

      // Sort chronologically ascending
      matchingShedScans.sort((a, b) => a.scan.createdAt.compareTo(b.scan.createdAt));

      if (matchingShedScans.isNotEmpty) {
        dynamicObservations.add(
          const CauseObservation(
            textEn: 'This disease was found again in this shed - check the shed cleaning and disinfection too.',
            textUr: 'اس شیڈ میں یہ بیماری دوبارہ ملی ہے - شیڈ کی صفائی اور ڈس انفیکشن بھی چیک کر لو۔',
          ),
        );

        final lastSeverity = matchingShedScans.last.prediction.severity;
        final lastRank = _severityRank(lastSeverity);
        final currentRank = _severityRank(currentSeverity);

        if (currentRank > lastRank) {
          dynamicObservations.add(
            const CauseObservation(
              textEn: 'Severity is rising - see the vet immediately.',
              textUr: 'شدت بڑھ رہی ہے - فوراً ڈاکٹر کو دکھائیں۔',
              isUrgent: true,
            ),
          );
        }
      }
    }

    // ==========================================
    // Per-disease "pehle ye check karo" checklist
    // ==========================================
    final checklist = _getChecklistForDisease(normDisease);

    return DiseaseCauseEvaluation(
      shouldShow: true,
      dynamicObservations: dynamicObservations,
      checklistItems: checklist,
    );
  }

  static String _normalizeDisease(String code) {
    final lower = code.toLowerCase().trim();
    if (lower == 'ncd' || lower == 'newcastle') return 'newcastle';
    if (lower.contains('coccidiosis') || lower == 'cocci') return 'coccidiosis';
    if (lower.contains('salmonella') || lower == 'sal') return 'salmonella';
    if (lower.contains('healthy')) return 'healthy';
    return lower;
  }

  static int _severityRank(String? sev) {
    final s = sev?.toLowerCase().trim() ?? 'mild';
    if (s == 'severe') return 3;
    if (s == 'moderate') return 2;
    return 1;
  }

  static List<CauseChecklistItem> _getChecklistForDisease(String normDisease) {
    switch (normDisease) {
      case 'coccidiosis':
        return const [
          CauseChecklistItem(
            textEn: 'Damp litter - when litter moisture exceeds 30%, pathogens survive and sporulate; at 21-32 C they mature in 1-2 days.',
            textUr: 'گیلا لٹر - لٹر کی نمی 30٪ سے زیادہ ہو تو جراثیم زندہ رہتے اور پھیلتے ہیں؛ 21 تا 32 ڈگری گرمی میں 1 سے 2 دن میں تیار ہو جاتے ہیں۔',
          ),
          CauseChecklistItem(
            textEn: 'Rainy season - field studies found 72.9% prevalence during rains compared to 34.4% in dry weather.',
            textUr: 'بارش کا موسم - فیلڈ اسٹڈی میں بارش میں یہ بیماری 72.9٪ ملی، خشک موسم میں 34.4٪۔',
          ),
          CauseChecklistItem(
            textEn: 'Age 6 to 10 weeks - birds in this age bracket are most vulnerable.',
            textUr: 'عمر 6 سے 10 ہفتے - اس عمر کے پرندے سب سے زیادہ متاثر ہوتے ہیں۔',
          ),
          CauseChecklistItem(
            textEn: 'Floor litter system - floor-reared birds show far higher infection rates than caged birds.',
            textUr: 'زمین پر لٹر کا نظام - زمین پر رکھے پرندوں میں پنجروں والوں سے کہیں زیادہ بیماری پائی گئی۔',
          ),
          CauseChecklistItem(
            textEn: 'Feed medication deficiency or improper mixing - inadequate or unevenly mixed coccidiostats in feed trigger outbreaks.',
            textUr: 'خوراک میں دوا کی کمی یا غلط مکسنگ - فیڈ میں حفاظتی دوا کم ہو یا ٹھیک سے نہ ملی ہو تو بیماری پھیلتی ہے۔',
          ),
          CauseChecklistItem(
            textEn: 'Weakened immunity - concurrent diseases or toxic feed mold (mycotoxins) weaken the birds resistance.',
            textUr: 'کمزور مدافعت - دوسری بیماریاں یا خوراک میں زہریلی پھپھوندی (مائیکوٹاکسنز) پرندے کی قوت مدافعت توڑ دیتی ہیں۔',
          ),
        ];

      case 'newcastle':
        return const [
          CauseChecklistItem(
            textEn: 'The biggest cause of this disease is missing vaccination - check your vaccination record.',
            textUr: 'اس بیماری کی سب سے بڑی وجہ ویکسین کا نہ ہونا ہوتا ہے - اپنا ویکسینیشن ریکارڈ چیک کریں۔',
          ),
          CauseChecklistItem(
            textEn: 'Only the farmer\'s own people should enter the shed, wearing separate shed footwear - no outside visitors or vehicles inside.',
            textUr: 'شیڈ میں صرف اپنے بندے جائیں، الگ جوتے پہن کے - باہر کے لوگ اور گاڑیاں اندر نہ آئیں۔',
          ),
          CauseChecklistItem(
            textEn: 'Shed exhaust ventilation - check that exhaust fans are not blowing aerosol drafts into neighboring houses.',
            textUr: 'شیڈ کی ہوا کا اخراج - چیک کریں کہ ایگزاسٹ پنکھوں کی ہوا دوسرے قریبی شیڈز کی طرف تو نہیں جا رہی۔',
          ),
          CauseChecklistItem(
            textEn: 'Wild bird and pest contact - check shed netting and wire mesh for open gaps or bird entry.',
            textUr: 'جنگلی پرندوں اور چوہوں سے رابطہ - چیک کریں کہ شیڈ کی جالیوں میں کوئی سوراخ یا دراڑ تو نہیں۔',
          ),
        ];

      case 'salmonella':
        return const [
          CauseChecklistItem(
            textEn: 'Drinking water quality - check drinker lines and storage tanks for biofilm or bacterial contamination.',
            textUr: 'پینے کے پانی کی کوالٹی - پانی کی پائپ لائنوں اور ٹینک میں جراثیمی تہہ (بائیو فلم) چیک کریں۔',
          ),
          CauseChecklistItem(
            textEn: 'Feed storage conditions - check feed bags and bins for dampness or rodent pest droppings.',
            textUr: 'فیڈ اسٹوریج کے حالات - خوراک کی بوریوں کو نمی اور چوہوں کی بیٹھوں سے پاک ہونا چیک کریں۔',
          ),
          CauseChecklistItem(
            textEn: 'Hatchery source history - check day-old chick Salmonella screening certificate and parent flock status.',
            textUr: 'ہیچری کا ریکارڈ - چوزے لاتے وقت ہیچری کا سالمونیلا اسکریننگ سرٹیفکیٹ چیک کریں۔',
          ),
          CauseChecklistItem(
            textEn: 'Brooding temperature stress - check heat lamp distribution and draft protection around vent-pasted chicks.',
            textUr: 'بروڈنگ کا درجہ حرارت - چیک کریں کہ چوزوں کو سردی یا ڈرافٹ تو نہیں لگ رہا جس سے پاخانہ جم رہا ہو۔',
          ),
        ];

      default:
        return const [];
    }
  }
}
