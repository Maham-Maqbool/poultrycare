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

  // Helper method for dynamic localization
  static String get(String enText, String urText, bool isUrdu) {
    return isUrdu ? urText : enText;
  }
}
