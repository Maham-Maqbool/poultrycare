import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/mock/mock_scans_data.dart';
import '../../../data/models/treatment_model.dart';
import '../../../data/repositories/diagnostic_repository.dart';
import '../../../data/repositories/disease_repository.dart';

/// ScannerController manages camera capture, local gallery selection,
/// image quality validation, 3-question flock triage input, and diagnostic execution.
class ScannerController extends ChangeNotifier {
  final DiagnosticRepository _diagRepo;
  final DiseaseRepository _diseaseRepo;
  final ImagePicker _picker = ImagePicker();

  String? _selectedImagePath;
  String? _selectedFlockId = 'flock-101';
  String? _forcedDisease; // For demo testing specific classes
  bool _isLocalFile = false;
  String? _errorMessage;

  // 3 Clinical Flock Triage Questions
  String _lethargy = 'Under 10% of birds';
  String _intakeDrop = 'Reduced consumption';
  String _suddenMortality = 'None in 24h';

  // Validation checks
  bool _lightingPassed = true;
  bool _sharpnessPassed = true;
  bool _singleDroppingPassed = true;

  // Processing state
  bool _isAnalyzing = false;
  String _analysisStep = 'Ready';
  DiagnosticRecord? _lastResult;
  TreatmentModel? _lastTreatment;

  ScannerController(this._diagRepo, this._diseaseRepo);

  String? get selectedImagePath => _selectedImagePath;
  String? get selectedFlockId => _selectedFlockId;
  String? get forcedDisease => _forcedDisease;
  bool get isLocalFile => _isLocalFile;

  String get lethargy => _lethargy;
  String get intakeDrop => _intakeDrop;
  String get suddenMortality => _suddenMortality;

  bool get lightingPassed => _lightingPassed;
  bool get sharpnessPassed => _sharpnessPassed;
  bool get singleDroppingPassed => _singleDroppingPassed;
  bool get isImageValid => _lightingPassed && _sharpnessPassed && _singleDroppingPassed;

  bool get isAnalyzing => _isAnalyzing;
  String get analysisStep => _analysisStep;
  DiagnosticRecord? get lastResult => _lastResult;
  TreatmentModel? get lastTreatment => _lastTreatment;
  String? get errorMessage => _errorMessage;

  /// Resets the selected image viewfinder.
  void clearSelectedImage() {
    _selectedImagePath = null;
    _isLocalFile = false;
    _forcedDisease = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Captures a live photograph using the device camera.
  Future<bool> pickImageFromCamera() async {
    _errorMessage = null;
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
        _forcedDisease = null; // Unbiased AI inference on actual photo
        _lightingPassed = true;
        _sharpnessPassed = true;
        _singleDroppingPassed = true;
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
        _forcedDisease = null; // Unbiased AI inference on actual photo
        _lightingPassed = true;
        _sharpnessPassed = true;
        _singleDroppingPassed = true;
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
  void selectSampleImage(String path, {String? targetDisease}) {
    _selectedImagePath = path;
    _isLocalFile = false;
    _forcedDisease = targetDisease;
    _lightingPassed = true;
    _sharpnessPassed = true;
    _singleDroppingPassed = true;
    notifyListeners();
  }

  void setImagePath(String path, {String? targetDisease, bool isLocal = false}) {
    _selectedImagePath = path;
    _isLocalFile = isLocal;
    _forcedDisease = targetDisease;
    _lightingPassed = true;
    _sharpnessPassed = true;
    _singleDroppingPassed = true;
    notifyListeners();
  }

  /// Sets the active diagnostic record and optional treatment for viewing.
  void setLastResult(DiagnosticRecord record, [TreatmentModel? treatment]) {
    _lastResult = record;
    _lastTreatment = treatment;
    _selectedImagePath = record.scan.imagePath;
    _forcedDisease = record.prediction.predictedClass;
    notifyListeners();
  }

  void setFlockId(String? id) {
    _selectedFlockId = id;
    notifyListeners();
  }

  void setFlockSignals({
    required String lethargy,
    required String intakeDrop,
    required String suddenMortality,
  }) {
    _lethargy = lethargy;
    _intakeDrop = intakeDrop;
    _suddenMortality = suddenMortality;
    notifyListeners();
  }

  void toggleLighting(bool value) {
    _lightingPassed = value;
    notifyListeners();
  }

  void toggleSharpness(bool value) {
    _sharpnessPassed = value;
    notifyListeners();
  }

  void toggleSingleDropping(bool value) {
    _singleDroppingPassed = value;
    notifyListeners();
  }

  Future<DiagnosticRecord?> executeDiagnosis() async {
    if (_selectedImagePath == null || !isImageValid) return null;

    _isAnalyzing = true;
    _errorMessage = null;
    _analysisStep = 'Preprocessing image tensor (224x224 RGB)...';
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 150));
      _analysisStep = 'Executing on-device AI vision diagnosis...';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 150));
      _analysisStep = 'Synthesizing clinical flock triage rules...';
      notifyListeners();

      final record = await _diagRepo.runDiagnosis(
        imagePath: _selectedImagePath!,
        flockId: _selectedFlockId,
        forcedDisease: _forcedDisease,
        flockSignals: {
          'lethargy': _lethargy,
          'intakeDrop': _intakeDrop,
          'suddenMortality': _suddenMortality,
        },
      );

      _lastResult = record;
      if (record.prediction.predictedClass != null &&
          record.prediction.severity != null) {
        _lastTreatment = await _diseaseRepo.getTreatment(
          record.prediction.predictedClass!,
          record.prediction.severity!,
        );
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
