/// AppStrings provides localized string keys and text in English and Urdu
/// for smallholder farmers and veterinarians in PoultryCare.
class AppStrings {
  // Common
  static const String appName = 'PoultryCare';
  static const String appTagline = 'AI-Powered Poultry Health & Triage';

  // Navigation
  static const String navHome = 'Home';
  static const String navHomeUr = 'ہوم';
  static const String navScan = 'Scan';
  static const String navScanUr = 'اسکین';
  static const String navFlocks = 'Flocks';
  static const String navFlocksUr = 'فلاکس';
  static const String navLibrary = 'Library';
  static const String navLibraryUr = 'بیماریاں';
  static const String navProfile = 'Account';
  static const String navProfileUr = 'اکاؤنٹ';

  // Disease Names
  static const String diseaseHealthy = 'Healthy';
  static const String diseaseHealthyUr = 'صحت مند';
  static const String diseaseCoccidiosis = 'Coccidiosis';
  static const String diseaseCoccidiosisUr = 'کوکسیڈیوسس';
  static const String diseaseNcd = 'Newcastle Disease';
  static const String diseaseNcdUr = 'رانی کھیت کی بیماری';
  static const String diseaseSalmonella = 'Salmonella';
  static const String diseaseSalmonellaUr = 'سالمونیلا';

  // Severity Levels
  static const String severityMild = 'Mild';
  static const String severityMildUr = 'ہلکی شدت';
  static const String severityModerate = 'Moderate';
  static const String severityModerateUr = 'درمیانی شدت';
  static const String severitySevere = 'Severe';
  static const String severitySevereUr = 'شدید';

  // Urgency Levels
  static const String urgencyMonitor = 'Monitor Daily';
  static const String urgencyMonitorUr = 'روزانہ نگرانی کریں';
  static const String urgencyTreatToday = 'Treat Today';
  static const String urgencyTreatTodayUr = 'آج ہی علاج شروع کریں';
  static const String urgencyVetSoon = 'Consult Vet Soon';
  static const String urgencyVetSoonUr = 'ڈاکٹر سے جلد رابطہ کریں';
  static const String urgencyVetNow = 'Urgent Vet Required!';
  static const String urgencyVetNowUr = 'فوری ڈاکٹر سے رجوع کریں!';

  // Scanner UI Strings
  static const String cameraTitle = 'Take Photo with Camera';
  static const String cameraTitleUr = 'کیمرے سے تصویر کھینچیں';
  static const String cameraSubtitle = 'Point directly at fecal specimen under good light';
  static const String cameraSubtitleUr = 'روشنی میں مرغی کی تازہ بیٹ کی تصویر لیں';

  static const String galleryTitle = 'Select from Gallery';
  static const String galleryTitleUr = 'گیلری سے تصویر منتخب کریں';
  static const String gallerySubtitle = 'Choose an existing photo from your device';
  static const String gallerySubtitleUr = 'اپنے موبائل کی گیلری سے محفوظ تصویر چنیں';

  static const String sampleTitle = 'Test Sample Photos';
  static const String sampleTitleUr = 'نمونے کی تصاویر';
  static const String sampleSubtitle = 'Standard verified disease specimens';
  static const String sampleSubtitleUr = 'معائنے کے لیے معیاری نمونہ تصاویر';

  static const String triageTitle = 'Clinical Flock Triage (3 Questions)';
  static const String triageTitleUr = 'پرندوں کی جسمانی علامات (3 سوالات)';

  static const String lethargyQ = '1. Bird Lethargy & Wing Droop:';
  static const String lethargyQUr = '1. پرندوں میں سستی یا پر لٹکانا:';

  static const String intakeQ = '2. Feed & Water Consumption:';
  static const String intakeQUr = '2. دانے پانی کا استعمال:';

  static const String mortalityQ = '3. Sudden Mortality in Last 24 Hours:';
  static const String mortalityQUr = '3. پچھلے 24 گھنٹوں میں اموات:';

  static const String runDiagnosis = 'Run AI Disease & Severity Diagnosis';
  static const String runDiagnosisUr = 'اے آئی تشخیص اور شدت معلوم کریں';

  static const String callVet = 'Call Veterinary Expert';
  static const String callVetUr = 'ویٹرنری ڈاکٹر کو کال کریں';

  static const String emergencyHotlineLabel = 'Veterinary Helpline';

  // Helper method for dynamic localization
  static String get(String enText, String urText, bool isUrdu) {
    return isUrdu ? urText : enText;
  }
}
