import 'package:flutter/material.dart';
import '../data/models/diagnostic_record.dart';
import 'clinical_ratio_service.dart';

/// Represents a single diagnostic observation or checklist item
/// with bilingual text and an associated visual icon.
class CauseChecklistItem {
  final String textEn;
  final String textUr;
  final IconData icon;
  final bool isWarning;

  const CauseChecklistItem({
    required this.textEn,
    required this.textUr,
    required this.icon,
    this.isWarning = false,
  });

  String getText(bool isUrdu) => isUrdu ? textUr : textEn;
}

/// Aggregated output of the "Kyun hua hoga" signs and checklist evaluation.
class CauseChecklistResult {
  final List<CauseChecklistItem> observedSigns;
  final List<CauseChecklistItem> checklistItems;
  final bool isMonsoonActive;
  final bool hasRepeatInShed;
  final bool isSeverityRising;

  const CauseChecklistResult({
    required this.observedSigns,
    required this.checklistItems,
    this.isMonsoonActive = false,
    this.hasRepeatInShed = false,
    this.isSeverityRising = false,
  });

  bool get hasSigns => observedSigns.isNotEmpty;
  bool get hasChecklist => checklistItems.isNotEmpty;
  bool get shouldDisplay => hasSigns || hasChecklist;

  factory CauseChecklistResult.empty() => const CauseChecklistResult(
        observedSigns: [],
        checklistItems: [],
      );
}

/// Evaluates probable signs and standard biosecurity checklists for poultry diseases
/// using strictly on-device inputs (photo ratios, calendar season, and shed SQLite history).
class CauseChecklistService {
  // Static checklists per disease from veterinary literature (MSD Manual, field studies, biosecurity protocols)
  static const Map<String, List<CauseChecklistItem>> _diseaseChecklists = {
    'coccidiosis': [
      CauseChecklistItem(
        icon: Icons.water_drop_outlined,
        textEn:
            'Wet litter: if litter moisture exceeds 30%, oocysts survive and sporulate (at 21-32C they become infectious in 1-2 days). Check litter moisture.',
        textUr:
            'گیلا لٹر: لٹر کی نمی 30 فیصد سے زیادہ ہو تو جراثیم زندہ رہتے اور پھیلتے ہیں؛ 21 سے 32 ڈگری گرمی میں 1 سے 2 دن میں تیار ہو جاتے ہیں۔ برادے کی نمی چیک کرو۔',
      ),
      CauseChecklistItem(
        icon: Icons.cloud_outlined,
        textEn:
            'Rainy season: field studies show 72.9% prevalence during rains compared to 34.4% in dry periods. Check shed rain protection.',
        textUr:
            'بارش کا موسم: فیلڈ اسٹڈی میں بارش میں یہ بیماری 72.9 فیصد ملی، خشک موسم میں 34.4 فیصد۔ شیڈ کی حفاظت چیک کرو۔',
      ),
      CauseChecklistItem(
        icon: Icons.access_time_rounded,
        textEn:
            'Age 6 to 10 weeks: birds of this age are most severely affected. Check flock age.',
        textUr:
            'عمر 6 سے 10 ہفتے: اس عمر کے پرندے سب سے زیادہ متاثر ہوتے ہیں۔ فلاک کی عمر چیک کرو۔',
      ),
      CauseChecklistItem(
        icon: Icons.grid_view_rounded,
        textEn:
            'Floor litter system: birds reared on floor litter have much higher infection rates than caged birds. Check floor management.',
        textUr:
            'زمین پر لٹر والا سسٹم: زمین پر رکھے پرندوں میں پنجروں والوں سے کہیں زیادہ بیماری ملی۔ فرش کا نظام چیک کرو۔',
      ),
      CauseChecklistItem(
        icon: Icons.science_outlined,
        textEn:
            'Medication deficiency or poor mixing in feed: sub-therapeutic or improperly mixed coccidiostats trigger outbreaks. Check feed mixing.',
        textUr:
            'خوراک میں دوا کی کمی یا غلط مکسنگ: فیڈ میں روک تھام والی دوا کم ہو یا ٹھیک سے نہ ملی ہو تو آؤٹ بریک ہوتا ہے۔ فیڈ کی مکسنگ چیک کرو۔',
      ),
      CauseChecklistItem(
        icon: Icons.health_and_safety_outlined,
        textEn:
            'Weakened immunity: secondary diseases or feed mycotoxins weaken flock defenses. Check feed for mold.',
        textUr:
            'کمزور مدافعت: دوسری بیماریاں یا خوراک میں زہریلی پھپھوندی (مائیکوٹوکسنز) پرندے کو کمزور کر دیتی ہیں۔ خوراک میں پھپھوندی چیک کرو۔',
      ),
    ],
    'newcastle': [
      CauseChecklistItem(
        icon: Icons.vaccines_outlined,
        isWarning: true,
        textEn:
            'The biggest cause of this disease is missing vaccination: check your vaccination record.',
        textUr:
            'اس بیماری کی سب سے بڑی وجہ ویکسین کا نہ ہونا ہوتا ہے: اپنا ویکسینیشن ریکارڈ چیک کرو۔',
      ),
      CauseChecklistItem(
        icon: Icons.local_shipping_outlined,
        textEn:
            'Check vehicle and visitor movement onto farm premises: ensure entry disinfection and footbaths.',
        textUr:
            'فارم میں گاڑیوں اور بیرونی افراد کی آمدورفت چیک کرو: داخلے پر جراثیم کش فٹ باتھ استعمال کریں۔',
      ),
      CauseChecklistItem(
        icon: Icons.air_rounded,
        textEn:
            'Check shed ventilation and exhaust direction: prevent airborne aerosol transmission between sheds.',
        textUr:
            'شیڈ کی ہوا کا رخ چیک کرو: ایگزاسٹ پنکھوں کی ہوا قریبی شیڈز یا فارمز کی طرف تو نہیں جا رہی۔',
      ),
      CauseChecklistItem(
        icon: Icons.group_remove_outlined,
        textEn:
            'Check immediate isolation of coughing or trembling birds: quarantine affected sections.',
        textUr:
            'بیمار یا کھانسی والے پرندوں کی علیحدگی چیک کرو: متاثرہ پرندوں کو فوری طور پر الگ کریں۔',
      ),
    ],
    'salmonella': [
      CauseChecklistItem(
        icon: Icons.pest_control_outlined,
        textEn:
            'Check rodent and fly control: pests and rodents are primary vectors for Salmonella transmission.',
        textUr:
            'چوہوں اور مکھیوں کا کنٹرول چیک کرو: چوہے اور کیڑے سالمونیلا بیکٹیریا پھیلانے کی بڑی وجہ ہیں۔',
      ),
      CauseChecklistItem(
        icon: Icons.inventory_2_outlined,
        textEn:
            'Check feed storage: ensure feed bags are elevated, dry, and protected from vermin contamination.',
        textUr:
            'فیڈ اسٹور چیک کرو: خوراک کو اونچی اور خشک جگہ پر بند ڈرموں میں رکھا گیا ہے یا نہیں۔',
      ),
      CauseChecklistItem(
        icon: Icons.water_drop_outlined,
        textEn:
            'Check water header tanks and pipelines: sanitize and flush drinker lines to clear bacterial biofilm.',
        textUr:
            'پانی کی ٹینکیاں اور پائپ لائنز چیک کرو: بائیو فلم اور بیکٹیریا ختم کرنے کے لیے پائپ لائن فلش کریں۔',
      ),
      CauseChecklistItem(
        icon: Icons.thermostat_outlined,
        textEn:
            'Check brooder temperature (32-35C): prevent chilling and keep vent feathers clean on young chicks.',
        textUr:
            'بروڈر کا درجہ حرارت 32 سے 35 ڈگری چیک کرو: چھوٹے چوزوں کو سردی اور وینٹ کے جمنے سے بچائیں۔',
      ),
    ],
  };

  static String _normalizeDiseaseCode(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower.contains('newcastle') || lower == 'ncd') return 'newcastle';
    if (lower.contains('coccidiosis')) return 'coccidiosis';
    if (lower.contains('salmonella')) return 'salmonella';
    return 'healthy';
  }

  static int _severityRank(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower == 'severe') return 3;
    if (lower == 'moderate') return 2;
    return 1; // mild
  }

  /// Evaluates signs and checklist for a given diagnosis session.
  /// Strictly offline-first: uses device date, photo ratios, and local records.
  static CauseChecklistResult evaluate({
    required String diseaseCode,
    required String severity,
    ClinicalSignRatios? clinicalRatios,
    DateTime? scanDate,
    List<DiagnosticRecord>? historicalRecords,
    String? flockId,
    String? currentScanId,
    DateTime? dateOverride,
  }) {
    final normalizedDisease = _normalizeDiseaseCode(diseaseCode);

    // Hard rule: Show this section ONLY for Coccidiosis, Newcastle, Salmonella. NEVER for Healthy.
    if (normalizedDisease == 'healthy') {
      return CauseChecklistResult.empty();
    }

    final List<CauseChecklistItem> observedSigns = [];

    // --- Input 3 Check: Shed history (30-day window) ---
    bool hasRepeatInShed = false;
    bool isSeverityRising = false;
    final now = dateOverride ?? scanDate ?? DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    if (historicalRecords != null && historicalRecords.isNotEmpty) {
      final relevantScans = historicalRecords.where((r) {
        if (currentScanId != null && r.scan.id == currentScanId) return false;
        if (flockId != null && flockId.isNotEmpty && r.scan.flockId != flockId) return false;
        if (r.scan.createdAt.isBefore(thirtyDaysAgo)) return false;
        final d = _normalizeDiseaseCode(r.prediction.predictedClass ?? '');
        return d == normalizedDisease;
      }).toList();

      if (relevantScans.isNotEmpty) {
        hasRepeatInShed = true;

        // Check if severity is rising across recent scans for this disease in this shed
        final currentRank = _severityRank(severity);
        final hadLowerSeverity = relevantScans.any((r) {
          final pastRank = _severityRank(r.prediction.severity ?? 'mild');
          return pastRank < currentRank;
        });

        if (hadLowerSeverity) {
          isSeverityRising = true;
        }
      }
    }

    // --- Input 1: Photo ratios (already computed, no recomputation) ---
    bool bloodLineAdded = false;
    if (clinicalRatios != null) {
      // Watery ratio ABOVE the Healthy p95 ceiling (0.1676)
      if (clinicalRatios.wateryRatio > 0.1676) {
        observedSigns.add(
          const CauseChecklistItem(
            icon: Icons.water_drop_outlined,
            isWarning: true,
            textEn: 'Droppings are very watery: check heat stress and water intake first.',
            textUr: 'Droppings بہت گیلی ہیں: پہلے گرمی اور پانی کا استعمال چیک کرو۔',
          ),
        );
      }

      // Blood ratio ABOVE the Healthy p95 ceiling (0.2239)
      if (clinicalRatios.bloodRatio > 0.2239) {
        bloodLineAdded = true;
        if (isSeverityRising) {
          observedSigns.add(
            const CauseChecklistItem(
              icon: Icons.priority_high_rounded,
              isWarning: true,
              textEn:
                  'Blood is high: this points to intestinal inflammation. Severity is rising: see the vet immediately.',
              textUr:
                  'خون زیادہ ہے: یہ آنتڑیوں کی سوزش کی طرف اشارہ ہے۔ شدت بڑھ رہی ہے: فوراً ڈاکٹر کو دکھائیں۔',
            ),
          );
        } else {
          observedSigns.add(
            const CauseChecklistItem(
              icon: Icons.warning_amber_rounded,
              isWarning: true,
              textEn: 'Blood is high: this points to intestinal inflammation, show it to the vet.',
              textUr: 'خون زیادہ ہے: یہ آنتڑیوں کی سوزش کی طرف اشارہ ہے، ڈاکٹر کو دکھائیں۔',
            ),
          );
        }
      }
    }

    // If severity is rising and blood line did not already include the strengthened notice
    if (isSeverityRising && !bloodLineAdded) {
      observedSigns.add(
        const CauseChecklistItem(
          icon: Icons.trending_up_rounded,
          isWarning: true,
          textEn: 'Severity is rising: see the vet immediately.',
          textUr: 'شدت بڑھ رہی ہے: فوراً ڈاکٹر کو دکھائیں۔',
        ),
      );
    }

    // --- Input 2: Date / season (Monsoon in Pakistan = July to September, months 7-9) ---
    // ONLY for Coccidiosis, and ONLY in monsoon months
    final evalDate = dateOverride ?? now;
    final isMonsoon = evalDate.month >= 7 && evalDate.month <= 9;
    if (normalizedDisease == 'coccidiosis' && isMonsoon) {
      observedSigns.add(
        const CauseChecklistItem(
          icon: Icons.thunderstorm_outlined,
          isWarning: true,
          textEn:
              'Rainy season is the most dangerous time for this disease: check the litter for dampness.',
          textUr:
              'بارش کا موسم اس بیماری کے لیے سب سے خطرناک ہوتا ہے: لٹر کا گیلا پن چیک کرو۔',
        ),
      );
    }

    // --- Input 3: Shed recurrence sign ---
    if (hasRepeatInShed) {
      observedSigns.add(
        const CauseChecklistItem(
          icon: Icons.repeat_rounded,
          isWarning: true,
          textEn:
              'This disease keeps coming back in this shed: it is often linked to the shed environment and cleaning.',
          textUr:
              'اس شیڈ میں یہ بیماری بار بار آ رہی ہے: یہ اکثر شیڈ کے ماحول اور صفائی سے جڑا ہوتا ہے۔',
        ),
      );
    }

    // --- Static Per-Disease Checklist ---
    final checklist = _diseaseChecklists[normalizedDisease] ?? const [];

    return CauseChecklistResult(
      observedSigns: observedSigns,
      checklistItems: checklist,
      isMonsoonActive: isMonsoon,
      hasRepeatInShed: hasRepeatInShed,
      isSeverityRising: isSeverityRising,
    );
  }
}
