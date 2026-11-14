import '../models/disease_model.dart';

/// mockDiseasesData holds curated disease encyclopedia entries in English and Urdu
/// reflecting commercial poultry health diagnostics dataset.
final List<DiseaseModel> mockDiseasesData = [
  const DiseaseModel(
    code: 'coccidiosis',
    nameEn: 'Coccidiosis',
    nameUr: 'کوکسیڈیوسس',
    summaryEn:
        'A parasitic infection caused by Eimeria protozoa multiplying in intestinal walls, causing bloody droppings, weight loss, and reduced feed efficiency.',
    summaryUr:
        'یہ ایک طفیلی بیماری ہے جو آنتوں میں ایمیریا پروٹوزووا کے بڑھنے سے ہوتی ہے۔ اس سے پاخانے میں خون، سستی اور وزن میں کمی واقع ہوتی ہے۔',
    signsEn: [
      'Reddish or bloody fecal droppings with excess mucus',
      'Ruffled, unkempt feathers and droopy wings',
      'Huddling together near heat sources and severe lethargy',
      'Pale comb and wattles due to blood loss',
      'Marked reduction in water and feed consumption',
    ],
    signsUr: [
      'پاخانے میں خون یا سرخی مائل لیس دار مواد',
      'کھڑے ہوئے پر اور جھکے ہوئے پروں کے ساتھ سستی',
      'ایک جگہ اکٹھے ہو کر بیٹھنا اور شدید کمزوری',
      'خون کی کمی کے باعث چہرے اور کلغی کی زردی',
      'دانہ پانی کم کھانا یا چھوڑ دینا',
    ],
    baselineSeverity: 'moderate',
    baselineUrgency: 'treat_today',
    isNotifiable: false,
    displayOrder: 2,
  ),
  const DiseaseModel(
    code: 'ncd',
    nameEn: 'Newcastle Disease',
    nameUr: 'رانی کھیت کی بیماری',
    summaryEn:
        'A devastating, highly contagious viral disease affecting respiratory, nervous, and digestive systems with very high mortality. Legally reportable in most regions.',
    summaryUr:
        'یہ ایک انتہائی خطرناک اور تیزی سے پھیلنے والا وائرل انفیکشن ہے جس میں ہلاکتوں کی شرح بہت زیادہ ہوتی ہے۔ فوری قرنطینہ ضروری ہے۔',
    signsEn: [
      'Bright greenish, watery fecal diarrhea with foul odor',
      'Twisting of the head and neck (torticollis) or paralysis',
      'Gasping, coughing, sneezing, and nasal discharge',
      'Swelling of the head and eyes',
      'Sudden death of multiple birds within hours',
    ],
    signsUr: [
      'سبز مائل، پتلا اور بدبودار پاخانہ',
      'گردن کا مڑ جانا، جھٹکے اور فالج کی علامات',
      'سانس لینے میں شدید دشواری، کھانسی اور چھینکیں',
      'آنکھوں اور چہرے کی سوجن',
      'کچھ ہی گھنٹوں میں پرندوں کی اچانک ہلاکت',
    ],
    baselineSeverity: 'severe',
    baselineUrgency: 'vet_now',
    isNotifiable: true,
    displayOrder: 1, // Highest clinical urgency
  ),
  const DiseaseModel(
    code: 'salmonella',
    nameEn: 'Salmonella (Pullorum / Typhoid)',
    nameUr: 'سالمونیلا انفیکشن',
    summaryEn:
        'A bacterial disease causing systemic septicemia, white diarrhea, chalky vent pasting, and severe weakness, especially dangerous in chicks and young broilers.',
    summaryUr:
        'یہ ایک بیکٹیریل انفیکشن ہے جو سفید رنگ کا چونا جیسا پاخانہ بناتا ہے۔ چوزوں میں اس سے وینٹ کے پر چپک جاتے ہیں اور کمزوری بڑھ جاتی ہے۔',
    signsEn: [
      'Chalky white, watery diarrhea pasting around the vent feathers',
      'Dullness, reluctance to move, and closed eyes',
      'Abdominal swelling and laboured breathing',
      'High mortality in young chicks under 3 weeks',
      'Decreased egg production and shell abnormalities in layers',
    ],
    signsUr: [
      'سفید چونے جیسا پتلا پاخانہ جو دم اور پروں پر جم جائے',
      'آنکھیں بند کر کے گم سم کھڑے رہنا',
      'پیٹ کی سوزش اور سانس کی دشواری',
      'چھوٹے چوزوں میں زیادہ اموات کی شرح',
      'انڈے دینے کی صلاحیت میں نمایاں کمی',
    ],
    baselineSeverity: 'moderate',
    baselineUrgency: 'treat_today',
    isNotifiable: false,
    displayOrder: 3,
  ),
  const DiseaseModel(
    code: 'healthy',
    nameEn: 'Healthy (Normal Droppings)',
    nameUr: 'صحت مند پرندہ',
    summaryEn:
        'Normal poultry digestive output with firm consistency, brownish-green digested matter, and a distinct white uric acid cap. Indicates active, healthy birds.',
    summaryUr:
        'یہ صحت مند پرندے کا قدرتی فضول ہے جس میں ٹھوس ساخت، براؤن رنگ اور اوپر سفید یورک ایسڈ کی تہہ ہوتی ہے۔ پرندے بالکل چست ہیں۔',
    signsEn: [
      'Firm, well-formed cylindrical droppings',
      'Distinct white cap of uric acid crystals on top',
      'Active foraging, alert eyes, and smooth bright feathers',
      'Normal feed and water intake corresponding to flock age',
      'Consistent daily weight gain or expected laying percentage',
    ],
    signsUr: [
      'ٹھوس اور متوازن ساخت کا پاخانہ',
      'اوپر سفید یورک ایسڈ کی واضح اور صاف ٹوپی',
      'چست اور پھرتیلی حرکات، چمکدار پر اور صاف آنکھیں',
      'معمول کے مطابق خوراک اور پانی کا استعمال',
      'روزانہ وزن میں مناسب اضافہ یا انڈوں کا معمول',
    ],
    baselineSeverity: 'mild',
    baselineUrgency: 'monitor',
    isNotifiable: false,
    displayOrder: 4,
  ),
];
