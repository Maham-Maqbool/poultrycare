import '../models/treatment_model.dart';

/// mockTreatmentsData provides the 11 medical and biosecurity treatment protocols
/// across all valid disease and clinical severity pairs reflecting commercial veterinary protocols.
final List<TreatmentModel> mockTreatmentsData = [
  // 1. Coccidiosis: Mild
  const TreatmentModel(
    id: 'trt-coc-01',
    diseaseCode: 'coccidiosis',
    severity: 'mild',
    medicinesEn: [
      'Amprolium 20% Soluble Powder (1.25g per litre drinking water for 5 consecutive days)',
      'Vitamin K3 supplement (supports blood clotting and mucosal repair)',
      'Poultry electrolytes with probiotics (restores gut balance)',
    ],
    medicinesUr: [
      'ایمپروولیم 20 فیصد پاؤڈر (1.25 گرام فی لیٹر پانی، لگاتار 5 دن)',
      'وٹامن K3 سپلیمنٹ (خون جمنے اور آنتوں کی بحالی کے لیے)',
      'پروبائیوٹک اور الیکٹرولائٹس پاؤڈر',
    ],
    careStepsEn: [
      'Provide continuous medicated drinking water as the sole water source.',
      'Replace wet litter around drinkers with fresh, dry wood shavings.',
      'Avoid high-protein dense feed during acute intestinal stress.',
    ],
    careStepsUr: [
      'دوائی ملا تازہ پانی دن بھر پرندوں کو فراہم کریں۔',
      'برتنوں کے گرد گیلا برادہ ہٹا کر خشک برادہ بچھائیں۔',
      'ہاضمہ بہتر ہونے تک ہلکی خوراک دیں۔',
    ],
    biosecurityEn: [
      'Disinfect drinkers and feeders daily with poultry-safe sanitizer.',
      'Limit caretaker movement between different sheds.',
    ],
    biosecurityUr: [
      'پانی اور دانے کے برتن روزانہ جراثیم کش ادویات سے دھوئیں',
      'متاثرہ شیڈ سے دوسرے شیڈ میں آمدورفت محدود رکھیں۔',
    ],
    vetRequired: false,
    urgency: 'treat_today',
  ),

  // 2. Coccidiosis: Moderate
  const TreatmentModel(
    id: 'trt-coc-02',
    diseaseCode: 'coccidiosis',
    severity: 'moderate',
    medicinesEn: [
      'Toltrazuril 2.5% (Baycox equivalent: 1ml per litre for 2 consecutive days)',
      'High-dose Vitamin A and K3 complex (hastens intestinal epithelial regeneration)',
      'Broad-spectrum gut active acidifier in water',
    ],
    medicinesUr: [
      'ٹولٹرازورل 2.5 فیصد (1 ملی لیٹر فی لیٹر پانی، لگاتار 2 دن)',
      'وٹامن A اور K3 کا اضافی مکسچر',
      'پانی صاف کرنے والا ایسڈیفائر',
    ],
    careStepsEn: [
      'Isolate visibly lethargic birds into an infirmary pen immediately.',
      'Increase shed temperature by 1-2 degrees Celsius to combat chilling from shock.',
      'Flush water pipelines before administering Toltrazuril solution.',
    ],
    careStepsUr: [
      'سست اور خون آلود پرندوں کو فوراً دوسرے پرندوں سے الگ کریں۔',
      'شیڈ کا درجہ حرارت 1 سے 2 ڈگری بڑھائیں تاکہ چوزے سردی سے محفوظ رہیں۔',
      'دوائی ڈالنے سے پہلے پانی کی پائپ لائن اچھی طرح فلش کریں۔',
    ],
    biosecurityEn: [
      'Apply lime wash or agricultural powdered lime under new litter.',
      'Sterilize footwear with a potassium peroxymonosulfate footbath.',
    ],
    biosecurityUr: [
      'فرش پر نیا برادہ بچھانے سے پہلے چونا چھڑکیں۔',
      'شیڈ کے دروازے پر فٹ باتھ لازمی استعمال کریں۔',
    ],
    vetRequired: false,
    urgency: 'treat_today',
  ),

  // 3. Coccidiosis: Severe
  const TreatmentModel(
    id: 'trt-coc-03',
    diseaseCode: 'coccidiosis',
    severity: 'severe',
    medicinesEn: [
      'Sulfaclozine Sodium or Toltrazuril under direct veterinary prescription',
      'Injectable multi-vitamin and electrolyte resuscitation solution for collapsed birds',
      'Secondary bacterial prophylaxis (Amoxicillin or Neomycin as advised by vet)',
    ],
    medicinesUr: [
      'سلفا کلوژین سوڈیم یا ٹولٹرازورل (ڈاکٹر کے نسخے کے مطابق)',
      'شدید نڈھال پرندوں کے لیے الیکٹرولائٹ ڈراپس',
      'بیکٹیریل انفیکشن روکنے کے لیے اینٹی بائیوٹک',
    ],
    careStepsEn: [
      'Immediate physical triage: Separate non-ambulatory birds.',
      'Administer oral hydration syringe directly to birds unable to reach water.',
      'Do not delay calling a licensed poultry veterinarian.',
    ],
    careStepsUr: [
      'فوری معائنہ: بے ہوش یا گری ہوئی مرغیوں کو الگ کریں۔',
      'جو پرندے پانی نہ پی سکیں انہیں سرنج سے احتیاط سے الیکٹرولائٹ پلائیں۔',
      'بغیر کسی تاخیر کے فوری پولٹری ڈاکٹر سے رابطہ کریں۔',
    ],
    biosecurityEn: [
      'Strict quarantine of affected shed; complete visitor ban.',
      'Daily removal and deep burial or burning of dead carcasses.',
    ],
    biosecurityUr: [
      'متاثرہ شیڈ میں ہر قسم کا داخلہ بند کر دیں۔',
      'ہلاک ہونے والے پرندوں کو گہرے گڑھے میں دبا کر چونے کا سپرے کریں۔',
    ],
    vetRequired: true,
    urgency: 'vet_now',
  ),

  // 4. Newcastle Disease: Mild (Early / Suspected)
  const TreatmentModel(
    id: 'trt-ncd-01',
    diseaseCode: 'ncd',
    severity: 'mild',
    medicinesEn: [
      'There is no specific treatment for Newcastle disease - no medicine kills this virus.',
      'Supportive care only: High-potency Vitamin C + Vitamin E + Selenium in drinking water for hydration and comfort',
      'Emergency LaSota / Clone 30 vaccination ONLY with vet permission, for healthy birds only - never for sick birds',
    ],
    medicinesUr: [
      'رانی کھیت کا کوئی خاص علاج نہیں ہے - کوئی دوا اس وائرس کو ختم نہیں کرتی۔',
      'صرف دیکھ بھال اور طاقت: پانی میں وٹامن C، وٹامن E اور نمکیات (الیکٹرولائٹس) دیں تاکہ پرندوں میں پانی کی کمی نہ ہو',
      'ہنگامی ویکسینیشن (لیسوٹا / کلون 30) صرف ڈاکٹر کی اجازت سے اور صرف صحت مند پرندوں کے لیے - بیمار پرندوں کے لیے ہرگز نہیں',
    ],
    careStepsEn: [
      'Shut off shed exhaust toward adjacent farm houses to mitigate aerosol spread.',
      'Provide warm, clean drinking water with sugar and electrolytes.',
      'Alert neighboring poultry farms within a 3km perimeter immediately.',
    ],
    careStepsUr: [
      'ہوا کا رخ قریبی شیڈز کی طرف بند کریں۔',
      'نیم گرم پانی میں گلوکوز اور نمکیات ملا کر دیں۔',
      'ارد گرد کے پولٹری فارمرز کو فوری طور پر باخبر کریں۔',
    ],
    biosecurityEn: [
      'Zero movement of vehicles, egg trays, or feed bags off premises.',
      'Dip hands and boots in 2% Virkon-S solution before and after entry.',
    ],
    biosecurityUr: [
      'فارم سے باہر کسی گاڑی یا انڈوں کی ٹرے کی نقل و حرکت مکمل بند کریں۔',
      'ویرکون ایس جراثیم کش محلول سے بوٹ اور ہاتھ دھوئیں',
    ],
    vetRequired: true,
    urgency: 'vet_now',
  ),

  // 5. Newcastle Disease: Moderate
  const TreatmentModel(
    id: 'trt-ncd-02',
    diseaseCode: 'ncd',
    severity: 'moderate',
    medicinesEn: [
      'There is no specific treatment for Newcastle disease - no medicine kills this virus.',
      'Supportive care only: Warm drinking water with electrolytes and glucose to maintain hydration',
      'Supportive care only: Paracetamol or analgesic oral solution under vet guidance to reduce fever stress',
    ],
    medicinesUr: [
      'رانی کھیت کا کوئی خاص علاج نہیں ہے - کوئی دوا اس وائرس کو ختم نہیں کرتی۔',
      'صرف دیکھ بھال اور طاقت: نیم گرم پانی میں نمکیات (الیکٹرولائٹس) اور گلوکوز ملا کر دیں تاکہ پانی کی کمی نہ ہو',
      'صرف دیکھ بھال: تیز بخار اور سستی کم کرنے کے لیے ڈاکٹر کے مشورے سے پیراسیٹامول پولٹری محلول دیں',
    ],
    careStepsEn: [
      'Immediate total isolation of coughing and nervous symptom birds.',
      'Ensure adequate ventilation without creating cold drafts.',
      'Notify regional livestock extension officer for official reporting.',
    ],
    careStepsUr: [
      'گردن مروڑ اور سانس کی خرابی والی مرغیاں فوراً الگ کریں۔',
      'تازہ ہوا کا مناسب انتظام رکھیں مگر ٹھنڈی ہوا سے بچائیں۔',
      'محکمہ لائیو اسٹاک کے مقامی نمائندے کو اطلاع دیں۔',
    ],
    biosecurityEn: [
      'Total farm perimeter lockdown. Disinfect tires of any authorized vehicle.',
      'Cremate or deep-bury all mortal remains with agricultural slaked lime.',
    ],
    biosecurityUr: [
      'فارم کی مکمل ناکہ بندی کریں، گاڑیوں کے ٹائروں پر سپرے کریں۔',
      'مردہ پرندوں کو چونے کے ساتھ گہرا دفنائیں۔',
    ],
    vetRequired: true,
    urgency: 'vet_now',
  ),

  // 6. Newcastle Disease: Severe (Outbreak State)
  const TreatmentModel(
    id: 'trt-ncd-03',
    diseaseCode: 'ncd',
    severity: 'severe',
    medicinesEn: [
      'There is no specific treatment for Newcastle disease - no medicine kills this virus.',
      'Supportive care only: Hydration solution, electrolytes, and liver tonic only for surviving birds able to drink',
      'CRITICAL: Newcastle Disease is an official NOTIFIABLE disease. Follow government veterinary officer containment protocol.',
    ],
    medicinesUr: [
      'رانی کھیت کا کوئی خاص علاج نہیں ہے - کوئی دوا اس وائرس کو ختم نہیں کرتی۔',
      'صرف دیکھ بھال اور طاقت: جو پرندے پانی پی سکتے ہیں انہیں نمکیات اور جگر کا ٹانک دیں',
      'انتہائی اہم: یہ ایک ہنگامی اور قانوناً رپورٹ ہونے والی بیماری ہے۔ سرکاری پولٹری ویٹرنری ڈاکٹر کی ہدایات پر فوری عمل کریں',
    ],
    careStepsEn: [
      'Do not sell, move, or process birds from this flock under any circumstance.',
      'Keep birds in a dimly lit, quiet environment to lessen nervous seizures.',
      'Document total mortality counts every 6 hours for veterinary investigation.',
    ],
    careStepsUr: [
      'کسی بھی صورت میں ان مرغیوں یا انڈوں کو مارکیٹ میں نہ بھیجیں',
      'شیڈ میں مدہم روشنی رکھیں تاکہ پرندے گھبراہٹ کے دوروں سے بچیں',
      'ہر 6 گھنٹے بعد ہلاکتوں کی تعداد نوٹ کریں۔',
    ],
    biosecurityEn: [
      'Mandatory Bio-containment: High-level glutaraldehyde or Virkon fogging.',
      'All protective clothing worn inside shed must be incinerated or boiled.',
    ],
    biosecurityUr: [
      'شیڈ میں جراثیم کش سپرے اور فوگنگ کریں۔',
      'استعمال شدہ کپڑے اور جوتے اچھی طرح جراثیم سے پاک کریں۔',
    ],
    vetRequired: true,
    urgency: 'vet_now',
  ),

  // 7. Salmonella: Mild
  const TreatmentModel(
    id: 'trt-sal-01',
    diseaseCode: 'salmonella',
    severity: 'mild',
    medicinesEn: [
      'Organic acidifier + Oregano essential oil blend in drinking water (pH 4.0)',
      'Water-soluble Enrofloxacin 10% (10mg per kg bodyweight for 3 to 5 days)',
      'B-Complex multi-vitamins to restore metabolic vigor',
    ],
    medicinesUr: [
      'پانی میں آرگینک ایسڈیفائر کا استعمال تاکہ بیکٹیریا ختم ہو',
      'اینروفلوکساسین 10 فیصد محلول (3 سے 5 دن)',
      'بی کمپلیکس وٹامن تاکہ پرندوں میں توانائی بحال ہو',
    ],
    careStepsEn: [
      'Inspect chicks individually and gently clean caked vent feathers with warm water.',
      'Maintain brooder temperature strictly at 32-35 degrees Celsius.',
      'Sanitize all water header tanks to eliminate biofilm reservoirs.',
    ],
    careStepsUr: [
      'چوزوں کی دم کے نیچے جمی ہوئی سفیدی کو نیم گرم پانی سے صاف کریں۔',
      'بروڈر کا درجہ حرارت 32 سے 35 ڈگری پر برقرار رکھیں۔',
      'پانی کی ٹینکیوں کی مکمل صفائی کریں۔',
    ],
    biosecurityEn: [
      'Rodent and fly eradication: Rodents are primary vectors of Salmonella.',
      'Store poultry feed in elevated, airtight dry containers.',
    ],
    biosecurityUr: [
      'چوہوں اور مکھیوں کا فوری خاتمہ کریں جو یہ بیماری پھیلاتے ہیں',
      'فیڈ کو اونچی اور خشک جگہ پر بند ڈرموں میں رکھیں۔',
    ],
    vetRequired: false,
    urgency: 'treat_today',
  ),

  // 8. Salmonella: Moderate
  const TreatmentModel(
    id: 'trt-sal-02',
    diseaseCode: 'salmonella',
    severity: 'moderate',
    medicinesEn: [
      'Fosfomycin + Tylosin water soluble formula (prescribed antibacterial)',
      'Vitamin AD3E complex for immune support',
      'Prebiotic mannooligosaccharides (MOS) in feed to competitively exclude bacteria',
    ],
    medicinesUr: [
      'فاسفومائسن اینٹی بائیوٹک پاؤڈر پانی میں',
      'وٹامن AD3E قطرے پانی میں شامل کریں',
      'فیڈ میں پروبائیوٹک مکس کریں',
    ],
    careStepsEn: [
      'Separate pasting chicks into an intensive recovery warmer box.',
      'Check feed for mold or mycotoxins which worsen enteritis.',
      'Increase feeder space so weakened chicks are not pushed away.',
    ],
    careStepsUr: [
      'بیمار چوزوں کو الگ گرم باکس میں رکھیں۔',
      'خوراک چیک کریں کہ پھپھوندی یا نمی نہ ہو۔',
      'برتن زیادہ رکھیں تاکہ کمزور چوزے بھی پیٹ بھر سکیں۔',
    ],
    biosecurityEn: [
      'Wear disposable gloves when handling pasty chicks; Salmonella is zoonotic.',
      'Disinfect floor with chlorhexidine or quaternary ammonium compound.',
    ],
    biosecurityUr: [
      'چوزوں کو پکڑتے وقت دستانے پہنیں کیونکہ یہ انسانوں میں بھی جا سکتی ہے',
      'فرش پر جراثیم کش سپرے کریں۔',
    ],
    vetRequired: false,
    urgency: 'treat_today',
  ),

  // 9. Salmonella: Severe
  const TreatmentModel(
    id: 'trt-sal-03',
    diseaseCode: 'salmonella',
    severity: 'severe',
    medicinesEn: [
      'Veterinary sensitivity culture test recommended prior to heavy antibiotic dosage',
      'Florfenicol 10% solution or Gentamicin under veterinary oversight',
      'Dextrose + amino acid electrolyte revival solution',
    ],
    medicinesUr: [
      'ڈاکٹر سے اینٹی بائیوٹک ٹیسٹ کروا کر صحیح دوائی منتخب کریں',
      'فلورفینیکول اینٹی بائیوٹک ڈاکٹر کی نگرانی میں',
      'گلوکوز اور امائنو ایسڈ ملا پانی',
    ],
    careStepsEn: [
      'Isolate all severely impacted clusters immediately.',
      'Submit fresh fecal swab samples to local veterinary diagnostic lab.',
      'Halt all routine vaccination until the acute bacterial crisis is resolved.',
    ],
    careStepsUr: [
      'شدید متاثرہ پرندوں کو فوری الگ کریں۔',
      'پاخانے کا نمونہ سرکاری ویٹرنری لیب میں بھیجیں۔',
      'بیماری ختم ہونے تک کوئی نئی ویکسین نہ کریں۔',
    ],
    biosecurityEn: [
      'Intense zoonosis precautions: Wash hands thoroughly with antibacterial soap.',
      'Sterilize footwear and replace litter completely in infected section.',
    ],
    biosecurityUr: [
      'انسانوں کی حفاظت کے لیے صابن سے بار بار ہاتھ دھوئیں',
      'شیڈ کا گندا برادہ مکمل ہٹا کر نیا اور صاف برادہ بچھائیں۔',
    ],
    vetRequired: true,
    urgency: 'vet_now',
  ),

  // 10. Healthy: Mild / Standard
  const TreatmentModel(
    id: 'trt-hlt-01',
    diseaseCode: 'healthy',
    severity: 'mild',
    medicinesEn: [
      'No medical treatment needed. Flocks show normal digestion.',
      'Routine probiotic water booster (once weekly maintenance)',
      'Balanced multivitamin & amino acid supplement during hot weather',
    ],
    medicinesUr: [
      'کسی دوائی کی ضرورت نہیں، پرندے مکمل صحت مند ہیں',
      'ہفتے میں ایک بار ہاضمے کا سیرپ دیا جا سکتا ہے',
      'گرمی کے موسم میں ہلکے وٹامنز دینا فائدہ مند ہے',
    ],
    careStepsEn: [
      'Maintain standard feeding and clean water schedules.',
      'Inspect droppings daily at morning feeding time.',
      'Ensure proper shed cross-ventilation and dry litter maintenance.',
    ],
    careStepsUr: [
      'صاف پانی اور وقت پر خوراک جاری رکھیں۔',
      'روزانہ صبح کے وقت پاخانے کا باقاعدہ معائنہ کریں۔',
      'شیڈ میں مناسب ہوا کا گزر اور برادے کو خشک رکھیں۔',
    ],
    biosecurityEn: [
      'Maintain routine entry footbaths and farm perimeter hygiene.',
      'Follow regional vaccination schedule strictly according to flock age.',
    ],
    biosecurityUr: [
      'فارم پر صفائی کا معمول جاری رکھیں۔',
      'شیڈول کے مطابق وقت پر ویکسین ضرور کروائیں۔',
    ],
    vetRequired: false,
    urgency: 'monitor',
  ),

  // 11. Healthy: Moderate / Precautionary
  const TreatmentModel(
    id: 'trt-hlt-02',
    diseaseCode: 'healthy',
    severity: 'moderate',
    medicinesEn: [
      'No antibiotics needed.',
      'Liver tonic and gut acidifier to support stress resilience',
      'Immune booster before scheduled vaccination',
    ],
    medicinesUr: [
      'اینٹی بائیوٹک کی قطعی ضرورت نہیں ہے',
      'جگر کا ٹانک اور قوت مدافعت کے قطرے دیے جا سکتے ہیں',
      'ویکسین سے پہلے قوت بخش سیرپ استعمال کریں',
    ],
    careStepsEn: [
      'Ensure drinking water temperature remains below 25 degrees Celsius.',
      'Routinely turn litter to prevent moisture accumulation.',
      'Monitor feed intake against standard breed growth tables.',
    ],
    careStepsUr: [
      'پانی کا درجہ حرارت زیادہ گرم نہ ہونے دیں۔',
      'برادے کو الٹ پلٹ کرتے رہیں تاکہ نمی نہ جمے۔',
      'وزن اور خوراک کے ریکارڈ پر نظر رکھیں۔',
    ],
    biosecurityEn: [
      'Maintain standard biosecurity protocols and visitor logs.',
      'Inspect feed bins for moisture or fungal growth weekly.',
    ],
    biosecurityUr: [
      'فارم پر آنے والے افراد کا ریکارڈ رکھیں',
      'دانے کے اسٹور میں نمی اور کیڑوں کی باقاعدہ جانچ کریں۔',
    ],
    vetRequired: false,
    urgency: 'monitor',
  ),
];
