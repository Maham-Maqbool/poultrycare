import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/diagnostic_record.dart';
import '../../../data/models/treatment_model.dart';
import '../../../data/repositories/diagnostic_repository.dart';
import '../../../data/repositories/disease_repository.dart';
import '../../../services/image_quality_service.dart';
import '../../../services/clinical_ratio_service.dart';

/// ScannerController manages camera capture, local gallery selection,
/// automated real-time image quality validation, 3-question flock triage input,
/// and diagnostic execution.
class ScannerController extends ChangeNotifier {
  final DiagnosticRepository _diagRepo;
  final DiseaseRepository _diseaseRepo;
  final ImagePicker _picker = ImagePicker();

  String? _selectedImagePath;
  String? _selectedFlockId;
  bool _isLocalFile = false;
  String? _errorMessage;

  // Clinical sign pixel ratios and derived severity
  ClinicalSignRatios? _clinicalRatios;

  // 3 Clinical Flock Triage Questions (start unselected / null)
  String? _lethargy;
  String? _intakeDrop;
  String? _suddenMortality;

  // Automated image quality report (starts at initial / not checked)
  ImageQualityReport _qualityReport = ImageQualityReport.initial();
  bool _qualityCheckFailed = false;

  // Processing state
  bool _isAnalyzing = false;
  String _analysisStep = 'Ready';
  DiagnosticRecord? _lastResult;
  TreatmentModel? _lastTreatment;

  ScannerController(this._diagRepo, this._diseaseRepo);

  String? get selectedImagePath => _selectedImagePath;
  String? get selectedFlockId => _selectedFlockId;
  bool get isLocalFile => _isLocalFile;
  ClinicalSignRatios? get clinicalRatios => _clinicalRatios;

  String? get lethargy => _lethargy;
  String? get intakeDrop => _intakeDrop;
  String? get suddenMortality => _suddenMortality;

  ImageQualityReport get qualityReport => _qualityReport;
  bool get isCheckingQuality => _isAnalyzing;
  bool get lightingPassed => _qualityReport.lightingStatus == QualityCheckStatus.passed;
  bool get sharpnessPassed => _qualityReport.sharpnessStatus == QualityCheckStatus.passed;
  bool get isImageValid => _selectedImagePath != null && !_qualityCheckFailed;
  bool get isQualityFailed => _qualityCheckFailed;
  bool get isTriageComplete => _lethargy != null && _intakeDrop != null && _suddenMortality != null;

  bool get isAnalyzing => _isAnalyzing;
  String get analysisStep => _analysisStep;
  DiagnosticRecord? get lastResult => _lastResult;
  TreatmentModel? get lastTreatment => _lastTreatment;
  String? get errorMessage => _errorMessage;

  /// Resets the selected image viewfinder.
  void clearSelectedImage() {
    _selectedImagePath = null;
    _isLocalFile = false;
    _errorMessage = null;
    _qualityCheckFailed = false;
    _qualityReport = ImageQualityReport.initial();
    _clinicalRatios = null;
    _lethargy = null;
    _intakeDrop = null;
    _suddenMortality = null;
    notifyListeners();
  }

  /// Computes clinical sign pixel ratios and derived severity score on-device.
  Future<void> _computeClinicalRatios(String path) async {
    try {
      _clinicalRatios = await ClinicalRatioService.computeFromPath(path);
      notifyListeners();
    } catch (e) {
      debugPrint('[ScannerController] Notice computing clinical ratios: $e');
    }
  }

  /// Evaluates lighting and focal sharpness silently on the chosen photo.
  Future<ImageQualityReport> evaluateQualitySilently() async {
    if (_selectedImagePath == null) return ImageQualityReport.initial();
    final report = await ImageQualityService.evaluateImage(_selectedImagePath!);
    _qualityReport = report;
    _qualityCheckFailed = !report.isPassed;
    if (_qualityCheckFailed) {
      _errorMessage = report.getPrimaryFailureMessage(false);
    }
    notifyListeners();
    return report;
  }

  /// Captures a live photograph using the device camera.
  Future<bool> pickImageFromCamera() async {
    _errorMessage = null;
    _qualityCheckFailed = false;
    _qualityReport = ImageQualityReport.initial();
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );
      if (photo != null) {
        _selectedImagePath = photo.path;
        _isLocalFile = true;
        _errorMessage = null;
        _qualityCheckFailed = false;
        _qualityReport = ImageQualityReport.initial();
        _computeClinicalRatios(photo.path);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ScannerController] Camera capture error: $e');
      _errorMessage = 'Camera access was denied or cancelled: $e';
      notifyListeners();
      return false;
    }
  }

  /// Selects an authentic poultry photo from local device gallery.
  Future<bool> pickImageFromGallery() async {
    _errorMessage = null;
    _qualityCheckFailed = false;
    _qualityReport = ImageQualityReport.initial();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );
      if (image != null) {
        _selectedImagePath = image.path;
        _isLocalFile = true;
        _errorMessage = null;
        _qualityCheckFailed = false;
        _qualityReport = ImageQualityReport.initial();
        _computeClinicalRatios(image.path);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ScannerController] Gallery picker error: $e');
      _errorMessage = 'Gallery access error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Selects one of the curated standard poultry test samples.
  /// Does NOT force the disease: the on-device AI model classifies the photo organically.
  void selectSampleImage(String path) {
    _selectedImagePath = path;
    _isLocalFile = false;
    _errorMessage = null;
    _qualityCheckFailed = false;
    _qualityReport = ImageQualityReport.initial();
    _computeClinicalRatios(path);
    notifyListeners();
  }

  void setImagePath(String path, {bool isLocal = false}) {
    _selectedImagePath = path;
    _isLocalFile = isLocal;
    _errorMessage = null;
    _qualityCheckFailed = false;
    _qualityReport = ImageQualityReport.initial();
    _computeClinicalRatios(path);
    notifyListeners();
  }

  /// Sets the active diagnostic record and optional treatment for viewing.
  void setLastResult(DiagnosticRecord record, [TreatmentModel? treatment]) {
    _lastResult = record;
    _lastTreatment = treatment;
    notifyListeners();
  }

  void setFlockId(String? id) {
    _selectedFlockId = id;
    notifyListeners();
  }

  void setFlockSignals({
    String? lethargy,
    String? intakeDrop,
    String? suddenMortality,
  }) {
    if (lethargy != null) _lethargy = lethargy;
    if (intakeDrop != null) _intakeDrop = intakeDrop;
    if (suddenMortality != null) _suddenMortality = suddenMortality;
    notifyListeners();
  }

  Future<DiagnosticRecord?> executeDiagnosis() async {
    if (_selectedImagePath == null || !isTriageComplete) return null;

    _isAnalyzing = true;
    _errorMessage = null;
    _qualityCheckFailed = false;
    _analysisStep = 'Validating specimen image quality...';
    notifyListeners();

    try {
      // 1. Silent automatic quality checks before inference
      final qualityReport =
          await ImageQualityService.evaluateImage(_selectedImagePath!);
      _qualityReport = qualityReport;

      if (!qualityReport.isPassed) {
        _isAnalyzing = false;
        _qualityCheckFailed = true;
        _errorMessage = qualityReport.getPrimaryFailureMessage(false);
        _analysisStep = 'Quality check failed';
        notifyListeners();
        return null;
      }

      // 2. Preprocessing & model inference
      _analysisStep = 'Preprocessing image tensor (224x224 RGB)...';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 100));
      _analysisStep = 'Executing on-device AI vision diagnosis...';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 100));
      _analysisStep = 'Synthesizing clinical flock triage rules...';
      notifyListeners();

      final record = await _diagRepo.runDiagnosis(
        imagePath: _selectedImagePath!,
        flockId: _selectedFlockId,
        flockSignals: {
          'lethargy': _lethargy ?? 'None',
          'intakeDrop': _intakeDrop ?? 'Normal',
          'suddenMortality': _suddenMortality ?? 'None in 24h',
          if (_clinicalRatios != null) ...{
            'wateryRatio': _clinicalRatios!.wateryRatio,
            'bloodRatio': _clinicalRatios!.bloodRatio,
            'abnormalRatio': _clinicalRatios!.abnormalRatio,
            'ratioScore': _clinicalRatios!.severityScore,
          },
        },
      );

      _lastResult = record;
      try {
        if (record.prediction.predictedClass != null &&
            record.prediction.severity != null &&
            record.prediction.predictedClass != 'healthy') {
          _lastTreatment = await _diseaseRepo.getTreatment(
            record.prediction.predictedClass!,
            record.prediction.severity!,
          );
        } else {
          _lastTreatment = null;
        }
      } catch (e) {
        debugPrint('[ScannerController] Treatment lookup error: $e');
        _lastTreatment = null;
      }

      _isAnalyzing = false;
      _analysisStep = 'Complete';
      notifyListeners();
      return record;
    } catch (e) {
      debugPrint('[ScannerController] Diagnosis execution error: $e');
      _isAnalyzing = false;
      _errorMessage = 'Diagnosis failed: $e';
      _analysisStep = 'Analysis error';
      notifyListeners();
      return null;
    }
  }

  Future<void> submitFeedback({
    bool? wasHelpful,
    String? actualClass,
    bool confirmedByVet = false,
    String? comment,
  }) async {
    if (_lastResult == null) return;
    await _diagRepo.submitFeedback(
      _lastResult!.scan.id,
      wasHelpful: wasHelpful,
      actualClass: actualClass,
      confirmedByVet: confirmedByVet,
      comment: comment,
    );
    notifyListeners();
  }
}
