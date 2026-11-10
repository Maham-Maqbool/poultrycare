/// DiseaseAudioService provides dynamic disease audio and voice script mapping
/// for the 4 diagnostic poultry classes: Coccidiosis, Newcastle Disease, Salmonella, and Healthy.
/// Ensures that every disease has its own dedicated audio file path, TTS speech synthesis script,
/// accurate Urdu/English clinical symptoms, and veterinary treatments.
library;

enum PoultryDiseaseType {
  coccidiosis,
  newcastle,
  salmonella,
  healthy,
}

class DiseaseAudioProfile {
  final PoultryDiseaseType type;
  final String canonicalName;
  final String urduName;
  final String audioAssetPath;
  final String symptomsUrdu;
  final String symptomsEn;
  final String treatmentUrdu;
  final String treatmentEn;
  final List<String> medicationsUrdu;
  final List<String> medicationsEn;
  final List<String> biosecurityUrdu;
  final List<String> biosecurityEn;
  final String baseTtsUrdu;
  final String baseTtsEn;

  const DiseaseAudioProfile({
    required this.type,
    required this.canonicalName,
    required this.urduName,
    required this.audioAssetPath,
    required this.symptomsUrdu,
    required this.symptomsEn,
    required this.treatmentUrdu,
    required this.treatmentEn,
    required this.medicationsUrdu,
    required this.medicationsEn,
    required this.biosecurityUrdu,
    required this.biosecurityEn,
    required this.baseTtsUrdu,
    required this.baseTtsEn,
  });

  /// Dynamically synthesizes the spoken audio script tailored to the model's
  /// predicted class, confidence percentage, and clinical severity level.
  /// For encyclopedia / library overviews (where confidenceScore is null),
  /// no certainty claim is stated (no "high certainty", no "100%", no "اعلیٰ یقین").
  String buildSpokenScript({
    required bool isUrdu,
    String? severity,
    double? confidenceScore,
  }) {
    final sevStr = severity?.toLowerCase() ?? 'mild';

    if (isUrdu) {
      String sevUrdu;
      switch (sevStr) {
        case 'severe':
          sevUrdu = 'شدید';
          break;
        case 'moderate':
          sevUrdu = 'درمیانی';
          break;
        case 'uncertain':
          sevUrdu = 'غیر یقینی';
          break;
        default:
          sevUrdu = 'ہلکی';
      }

      // If confidence is present, format it dynamically to 1 decimal place (e.g. 96.0 فیصد)
      if (confidenceScore != null) {
        final confPercent = '${(confidenceScore * 100).toStringAsFixed(1)} فیصد';
        switch (type) {
          case PoultryDiseaseType.newcastle:
            return 'محترم کسان: آپ کے نمونے میں رانی کھیت کی خطرناک علامات پائی گئی ہیں، اس کی شدت $sevUrdu اور یقین $confPercent ہے۔ علامات میں سبز پتلی بیٹھیں، گردن مڑنا، لرزنا اور سانس کی تنگی شامل ہیں۔ بیمار پرندوں کو فوراً صحت مند پرندوں سے الگ کر دیں، شیڈ میں باہر کے لوگوں کو نہ آنے دیں، پانی میں الیکٹرولائٹس شامل کریں اور فوراً ویٹرنری ڈاکٹر سے رابطہ کریں۔';

          case PoultryDiseaseType.coccidiosis:
            return 'محترم کسان: آپ کے فلاک میں کوکسیڈیوسس یعنی خونی پیچش کی تشخیص ہوئی ہے، اس کی شدت $sevUrdu اور یقین $confPercent ہے۔ علامات میں بیٹھوں میں خون آنا، پرندوں کا سست بیٹھنا اور خوراک کی کمی شامل ہے۔ علاج کے لیے پینے کے پانی میں ایمپرولیم یا ٹولٹرازوریل دو دن شامل کریں، خون روکنے کے لیے وٹامن کے دیں اور شیڈ کا تمام گیلا برادہ فوراً تبدیل کر دیں۔';

          case PoultryDiseaseType.salmonella:
            return 'محترم کسان: آپ کے نمونے میں سالمونیلا یعنی سفید پیچش کی تصدیق ہوئی ہے، اس کی شدت $sevUrdu اور یقین $confPercent ہے۔ علامات میں سفید چاک جیسا فضلہ اور پرندوں کا سردی سے اکٹھا ہو کر سست بیٹھنا شامل ہے۔ علاج کے لیے پینے کے پانی میں اینروفلوکساسین یا نیومائسن تین سے پانچ دن دیں اور پانی کے برتنوں کو روزانہ جراثیم کش محلول سے صاف کریں۔';

          case PoultryDiseaseType.healthy:
            return 'محترم کسان: مبارک ہو، آپ کا پرندہ اور اس کا نظام انہضام بالکل تندرست اور نارمل ہے، جس میں $confPercent یقین ہے۔ فضلہ بہترین بناوٹ میں ہے۔ اس حالت کو برقرار رکھنے کے لیے پرندوں کو متوازن خوراک اور صاف پانی دیں اور حفاظتی ٹیکوں کا شیڈول وقت پر مکمل رکھیں۔';
        }
      } else {
        // Library overview: State NO certainty claims at all
        switch (type) {
          case PoultryDiseaseType.newcastle:
            return 'محترم کسان: رانی کھیت پولٹری کی ایک انتہائی خطرناک اور متعدی وائرل بیماری ہے۔ اس کی علامات میں سبز پتلی بیٹھیں، گردن مڑنا، لرزنا اور سانس کی تنگی شامل ہیں۔ بیمار پرندوں کو فوراً صحت مند پرندوں سے الگ کر دیں، شیڈ میں بیرونی افراد کا داخلہ بند کریں، پانی میں الیکٹرولائٹس فراہم کریں اور بروقت ویکسینیشن کا شیڈول یقینی بنائیں۔';

          case PoultryDiseaseType.coccidiosis:
            return 'محترم کسان: کوکسیڈیوسس یعنی خونی پیچش پولٹری میں پروٹوزوا کی وجہ سے پھیلنے والی عام بیماری ہے۔ علامات میں بیٹھوں میں خون آنا، پرندوں کا سست بیٹھنا اور خوراک کی کمی شامل ہے۔ علاج کے لیے پینے کے پانی میں ایمپرولیم یا ٹولٹرازوریل دو دن شامل کریں، خون روکنے کے لیے وٹامن کے دیں اور شیڈ کا تمام گیلا برادہ فوراً تبدیل کر کے خشکی برقرار رکھیں۔';

          case PoultryDiseaseType.salmonella:
            return 'محترم کسان: سالمونیلا یعنی سفید پیچش ایک بیکٹیریل انفیکشن ہے۔ علامات میں سفید چاک جیسا فضلہ اور پرندوں کا سردی سے اکٹھا ہو کر سست بیٹھنا شامل ہے۔ علاج کے لیے پینے کے پانی میں اینروفلوکساسین یا نیومائسن تین سے پانچ دن دیں اور پانی کے برتنوں کو روزانہ جراثیم کش محلول سے صاف کریں۔';

          case PoultryDiseaseType.healthy:
            return 'محترم کسان: صحت مند پرندوں کا نظام انہضام نارمل ہوتا ہے اور فضلہ بہترین بناوٹ میں ہوتا ہے۔ اس حالت کو برقرار رکھنے کے لیے پرندوں کو متوازن خوراک اور صاف پانی دیں اور حفاظتی ٹیکوں کا شیڈول وقت پر مکمل رکھیں۔';
        }
      }
    } else {
      final sevCapitalized = sevStr.isNotEmpty
          ? '${sevStr[0].toUpperCase()}${sevStr.substring(1)}'
          : 'Mild';

      if (confidenceScore != null) {
        final confPercent = '${(confidenceScore * 100).toStringAsFixed(1)}%';
        switch (type) {
          case PoultryDiseaseType.newcastle:
            return 'Attention Farmer: High-risk Newcastle Disease indicators detected with $sevCapitalized severity and $confPercent model confidence. Clinical signs include watery greenish droppings, neck twisting, and respiratory distress. Immediately isolate symptomatic birds in quarantine, enforce strict biosecurity, provide electrolytes, and dial the emergency veterinary helpline immediately.';

          case PoultryDiseaseType.coccidiosis:
            return 'Farmer Notice: Coccidiosis protozoal infection diagnosed with $sevCapitalized severity and $confPercent confidence. Primary symptoms include bloody mucoid droppings, ruffled feathers, and loss of appetite. Treat immediately by administering Toltrazuril or Amprolium in drinking water for 48 hours, give Vitamin K to stop bleeding, and replace wet litter immediately.';

          case PoultryDiseaseType.salmonella:
            return 'Farmer Notice: Salmonella bacterial infection identified with $sevCapitalized severity and $confPercent confidence. Symptoms feature chalky white diarrhea pasting the vent and persistent huddling. Administer prescribed Enrofloxacin or Neomycin in drinking water for 3 to 5 days and thoroughly sanitize water drinker lines.';

          case PoultryDiseaseType.healthy:
            return 'Farmer Notice: Specimen analysis confirms normal healthy digestion with $confPercent confidence. Droppings exhibit proper consistency with white uric acid cap. No medication required. Maintain standard biosecurity protocols and balanced hydration.';
        }
      } else {
        // Library overview: State NO certainty claims at all
        switch (type) {
          case PoultryDiseaseType.newcastle:
            return 'Farmer Guide: Newcastle Disease is a severe and highly contagious viral poultry infection. Clinical signs include watery greenish droppings, torticollis neck twisting, tremors, and respiratory distress. Immediately quarantine affected birds, restrict flock access, administer electrolytes, and maintain strict biosecurity.';

          case PoultryDiseaseType.coccidiosis:
            return 'Farmer Guide: Coccidiosis is an intestinal protozoal infection affecting broilers and layers. Key symptoms include bloody mucoid droppings, ruffled plumage, and sharp feed intake drop. Treatment includes Toltrazuril or Amprolium in drinking water with Vitamin K, accompanied by immediate replacement of wet bedding litter.';

          case PoultryDiseaseType.salmonella:
            return 'Farmer Guide: Salmonella infection is a systemic bacterial disease in poultry. Key symptoms include white chalky vent pasting and severe huddling. Prescribed treatment includes veterinary-directed antibiotic therapy such as Enrofloxacin, alongside continuous disinfection of water lines.';

          case PoultryDiseaseType.healthy:
            return 'Farmer Guide: Healthy flock droppings exhibit normal consistency with a characteristic white uric acid cap. Maintain balanced nutritional feed, clean water sanitation, and standard vaccination schedules to sustain flock wellness.';
        }
      }
    }
  }
}

class DiseaseAudioService {
  /// Robust normalizer that parses any disease string into its canonical enum.
  static PoultryDiseaseType parseDisease(String? input) {
    if (input == null || input.trim().isEmpty) {
      return PoultryDiseaseType.healthy;
    }

    final clean = input.toLowerCase().trim();

    // Check Newcastle variations
    if (clean.contains('newcastle') ||
        clean.contains('ncd') ||
        clean.contains('ranikhet') ||
        clean.contains('rani khet') ||
        clean.contains('رانی کھیت') ||
        clean.contains('نیو کیسل') ||
        clean.contains('نیوکیسل')) {
      return PoultryDiseaseType.newcastle;
    }

    // Check Coccidiosis variations
    if (clean.contains('cocci') ||
        clean.contains('bloody') ||
        clean.contains('کوکسی') ||
        clean.contains('خونی پیچش')) {
      return PoultryDiseaseType.coccidiosis;
    }

    // Check Salmonella variations
    if (clean.contains('salmon') ||
        clean.contains('pullorum') ||
        clean.contains('typhoid') ||
        clean.contains('white diarrhea') ||
        clean.contains('سالمونیلا') ||
        clean.contains('سفید پیچش')) {
      return PoultryDiseaseType.salmonella;
    }

    // Default to Healthy
    return PoultryDiseaseType.healthy;
  }

  /// Returns the complete diagnostic audio profile based on disease input.
  static DiseaseAudioProfile getProfile(
    String? diseaseName, {
    String? severity,
    double? confidenceScore,
  }) {
    final type = parseDisease(diseaseName);
    return getProfileByType(type);
  }

  /// Maps each of the 4 classes to its specific audio profile.
  static DiseaseAudioProfile getProfileByType(PoultryDiseaseType type) {
    switch (type) {
      case PoultryDiseaseType.newcastle:
        return const DiseaseAudioProfile(
          type: PoultryDiseaseType.newcastle,
          canonicalName: 'Newcastle Disease',
          urduName: 'رانی کھیت کی بیماری (نیوکیسل)',
          audioAssetPath: 'assets/audio/newcastle.mp3',
          symptomsUrdu:
              'سبز پتلا پانی جیسا فضلہ، گردن مڑنا، لرزنا، اعصابی جھٹکے، سانس کی گھرگھراہٹ اور فلاک میں اچانک تیزی سے اموات۔',
          symptomsEn:
              'Watery greenish diarrhea, twisted neck (torticollis), tremors, neurological spasms, gasping, and sudden high flock mortality.',
          treatmentUrdu:
              'تمام بیمار پرندوں کو فوری قرنطینہ کریں۔ وائرل بیماری کے ثانوی جراثیمی حملے روکنے کے لیے اینٹی بائیوٹک اور پانی میں الیکٹرولائٹس اور وٹامن ای دیں۔ فوری ویٹرنری ہیلپ لائن پر رابطہ کریں۔',
          treatmentEn:
              'Immediately isolate symptomatic birds in quarantine. Provide broad-spectrum coverage for secondary bacterial infections, add electrolytes and Vitamin E/C in drinking water, and contact a veterinarian immediately.',
          medicationsUrdu: [
            'الیکٹرولائٹس + وٹامن ای اور سی (مدافعتی نظام کی بہتری)',
            'ایموکسیسلین یا ٹائلوسین (ثانوی انفیکشن سے بچاؤ)',
            'لا سوٹا / این ڈی ویکسین (صحت مند پرندوں کی ہنگامی ویکسینیشن)',
          ],
          medicationsEn: [
            'Electrolytes + Vitamin E & C (Immune booster)',
            'Amoxicillin or Tylosin (Secondary bacterial coverage)',
            'LaSota / ND Clone 30 Vaccine (Emergency flock ring vaccination)',
          ],
          biosecurityUrdu: [
            'متاثرہ شیڈ میں بیرونی گاڑیوں اور افراد کا داخلہ مکمل بند کریں',
            'مرنے والے پرندوں کو شیڈ سے دور گہرے گڑھے میں چونے کے ساتھ دبائیں',
            'پاؤں اور ہاتھوں کے لیے جراثیم کش اسپرے استعمال کریں',
          ],
          biosecurityEn: [
            'Lock down shed access to external visitors and equipment',
            'Deeply bury dead birds with agricultural lime away from water sources',
            'Use antiviral footbaths and sanitizer sprays at all shed entries',
          ],
          baseTtsUrdu:
              'محترم فارمر: آپ کے نمونے میں رانی کھیت کی علامات پائی گئی ہیں۔ سبز پتلی بیٹھیں اور گردن مڑنا اس کی خاص نشانیاں ہیں۔ بیمار پرندوں کو فوراً الگ کریں اور ویٹرنری ڈاکٹر سے رابطہ کریں۔',
          baseTtsEn:
              'Attention Farmer: Newcastle Disease indicators detected. Key signs include greenish diarrhea and neurological neck twisting. Isolate infected birds immediately and call veterinary support.',
        );

      case PoultryDiseaseType.coccidiosis:
        return const DiseaseAudioProfile(
          type: PoultryDiseaseType.coccidiosis,
          canonicalName: 'Coccidiosis',
          urduName: 'کوکسیڈیوسس (خونی پیچش)',
          audioAssetPath: 'assets/audio/coccidiosis.mp3',
          symptomsUrdu:
              'فضلے میں سرخ خون، لوتھڑے یا گہرا لیس دار مادہ، پر بکھرنا، پرندوں کا سر جھکا کر سست بیٹھنا اور بھوک کا نہ لگنا۔',
          symptomsEn:
              'Bloody mucoid droppings, blood clots, ruffled feathers, hunched posture, lethargy, decreased feed intake, and weight loss.',
          treatmentUrdu:
              'پینے کے پانی میں ایمپرولیم یا ٹولٹرازوریل دو دن کے لیے شامل کریں۔ خون کا اخراج روکنے کے لیے وٹامن کے دیں اور شیڈ کا تمام گیلا برادہ فوراً ہٹا کر نیا برادہ ڈالیں۔',
          treatmentEn:
              'Administer Toltrazuril 2.5% or Amprolium 20% in drinking water for 48 hours. Provide Vitamin K to control gut hemorrhaging and remove damp litter immediately.',
          medicationsUrdu: [
            'ٹولٹرازوریل 2.5 فیصد (1 ملی لیٹر فی لیٹر پانی - 48 گھنٹے)',
            'ایمپرولیم 20 فیصد پاؤڈر (پینے کے صاف پانی میں)',
            'وٹامن کے اور الیکٹرولائٹس (خون روکنے اور پانی کی کمی کے لیے)',
          ],
          medicationsEn: [
            'Toltrazuril 2.5% (1 ml per liter drinking water for 48h)',
            'Amprolium 20% Soluble Powder (In clean drinking water)',
            'Vitamin K + Electrolyte complex (Hemostasis and hydration)',
          ],
          biosecurityUrdu: [
            'ڈرنکرز کے ارد گرد کا گیلا برادہ فوری طور پر باہر نکالیں',
            'شیڈ میں نمی کو 50 فیصد سے کم رکھیں اور مناسب وینٹیلیشن دیں',
            'ہر روز پانی کے برتن اچھی طرح دھو کر اینٹی کوکسیڈیل محلول دیں',
          ],
          biosecurityEn: [
            'Excavate and replace damp litter under drinkers immediately',
            'Keep shed relative humidity below 50% with adequate ventilation',
            'Sanitize drinking founts daily prior to medicated water delivery',
          ],
          baseTtsUrdu:
              'محترم فارمر: آپ کے فلاک میں کوکسیڈیوسس یعنی خونی پیچش کی علامات ہیں۔ بیٹھوں میں خون آنا اس کی علامت ہے۔ فوری طور پر ایمپرولیم یا ٹولٹرازوریل کا علاج شروع کریں۔',
          baseTtsEn:
              'Farmer Notice: Coccidiosis detected with bloody mucoid droppings. Start Toltrazuril or Amprolium treatment in clean drinking water immediately.',
        );

      case PoultryDiseaseType.salmonella:
        return const DiseaseAudioProfile(
          type: PoultryDiseaseType.salmonella,
          canonicalName: 'Salmonella',
          urduName: 'سالمونیلا (سفید پیچش / فاول ٹائیفائیڈ)',
          audioAssetPath: 'assets/audio/salmonella.mp3',
          symptomsUrdu:
              'سفید چاک جیسا پتلا فضلہ جو پاخانے کے گرد چپک جاتا ہے، پرندوں کا سردی سے اکٹھے ہو کر سست بیٹھنا اور شدید پیاس لگنا۔',
          symptomsEn:
              'Chalky white diarrhea pasting the vent, severe weakness, huddling near heat sources, somnolence, and decreased appetite.',
          treatmentUrdu:
              'پینے کے پانی میں اینروفلوکساسین یا نیومائسن 3 سے 5 دن دیں اور پانی کی تمام نپل لائنز کو کلورین یا جراثیم کش دوا سے روزانہ واش کریں۔',
          treatmentEn:
              'Administer Enrofloxacin 10% or Neomycin in drinking water for 3 to 5 days. Flush and disinfect drinking water lines with chlorine or organic acids.',
          medicationsUrdu: [
            'اینروفلوکساسین 10 فیصد (1 ملی لیٹر فی 2 لیٹر پانی - 4 دن)',
            'نیومائسن سلفیٹ پاؤڈر (بیکٹیریل انفیکشن کے خاتمے کے لیے)',
            'جگر کا ٹانک اور وٹامن بی کمپلیکس (بھوک بڑھانے کے لیے)',
          ],
          medicationsEn: [
            'Enrofloxacin 10% (1 ml per 2 liters water for 4 days)',
            'Neomycin Sulfate Soluble Powder (Enteric antibacterial)',
            'Hepato-protective liver tonic + Vitamin B-complex',
          ],
          biosecurityUrdu: [
            'پینے کے پانی کو 2 سے 3 پی پی ایم کلورینیشن کے ذریعے جراثیم سے پاک رکھیں',
            'چوہوں اور کیڑوں کے خاتمے کے لیے ادویات کا اسپرے کریں',
            'شیڈ کے برادے کو خشک رکھیں اور فیڈ فیڈرز کو زمین سے اونچا رکھیں',
          ],
          biosecurityEn: [
            'Chlorinate flock drinking water at 2 to 3 PPM residual level',
            'Execute intensive rodent and wild bird exclusion controls',
            'Keep feeding troughs elevated above contaminated bedding litter',
          ],
          baseTtsUrdu:
              'محترم فارمر: آپ کے نمونے میں سالمونیلا یعنی سفید پیچش کے جراثیم ہیں۔ سفید چونا فضلہ اس کی نشانی ہے۔ اینروفلوکساسین دوا پانی میں شامل کریں اور پانی کے برتن صاف رکھیں۔',
          baseTtsEn:
              'Farmer Notice: Salmonella bacterial infection identified with chalky white diarrhea. Administer prescribed Enrofloxacin in water and sanitize drinking lines.',
        );

      case PoultryDiseaseType.healthy:
        return const DiseaseAudioProfile(
          type: PoultryDiseaseType.healthy,
          canonicalName: 'Healthy',
          urduName: 'تندرست و صحت مند فلاک',
          audioAssetPath: 'assets/audio/healthy.mp3',
          symptomsUrdu:
              'ٹھوس بھورے رنگ کا نارمل فضلہ جس پر سفید یورک ایسڈ کی کیپ موجود ہو۔ پرندے چست، چمکدار آنکھیں اور متوازن خوراک۔',
          symptomsEn:
              'Firm brownish dropping with white uric acid cap. Active, alert birds with bright eyes, smooth plumage, and normal feed intake.',
          treatmentUrdu:
              'کسی دوا کی ضرورت نہیں ہے۔ شیڈ کا درجہ حرارت اور بائیو سیکیورٹی برقرار رکھیں اور متوازن متناسب فیڈ اور صاف پانی جاری رکھیں۔',
          treatmentEn:
              'No medical intervention required. Maintain proper shed ventilation, strict biosecurity protocols, and optimal flock nutrition.',
          medicationsUrdu: [
            'کسی دوا کی ضرورت نہیں ہے (No Medication Needed)',
            'پروبائیوٹکس (ہاضمہ اور قوت مدافعت بہترین رکھنے کے لیے)',
            'الیکٹرولائٹس (شدید گرمی یا تناؤ کی صورت میں)',
          ],
          medicationsEn: [
            'No medication required (Flock within healthy baseline)',
            'Beneficial gut probiotics (Maintains normal microflora)',
            'Electrolytes during extreme heat stress periods',
          ],
          biosecurityUrdu: [
            'صاف اور تازہ پینے کا پانی مسلسل فراہم رکھیں',
            'شیڈ کا درجہ حرارت موسمی ضرورت کے مطابق ایڈجسٹ رکھیں',
            'شیڈ میں مناسب وینٹیلیشن اور ہوا کی آمد و رفت یقینی بنائیں',
          ],
          biosecurityEn: [
            'Ensure uninterrupted supply of fresh, tested drinking water',
            'Maintain optimal brooding and ambient temperature curves',
            'Ensure adequate air exchange to evacuate ammonia vapors',
          ],
          baseTtsUrdu:
              'محترم فارمر: مبارک ہو، آپ کا فلاک بالکل تندرست اور صحت مند ہے۔ متوازن خوراک، صاف پانی اور بائیو سیکیورٹی ایس او پیز پر عمل جاری رکھیں۔',
          baseTtsEn:
              'Farmer Notice: Digestive specimen confirms healthy normal conditions. Continue standard flock management and biosecurity protocols.',
        );
    }
  }
}

