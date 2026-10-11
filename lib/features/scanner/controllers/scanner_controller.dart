import 'package:flutter/material.dart';
import '../../../data/mock/mock_scans_data.dart';
import '../../../data/models/treatment_model.dart';
import '../../../data/repositories/diagnostic_repository.dart';
import '../../../data/repositories/disease_repository.dart';
import '../../../core/constants/app_assets.dart';

/// ScannerController manages image selection, quality validation,
/// 3-question flock triage input, and diagnostic execution.
class ScannerController extends ChangeNotifier {
  final DiagnosticRepository _diagRepo;
  final DiseaseRepository _diseaseRepo;

  String? _selectedImagePath = AppAssets.sampleCoccidiosis;
  String? _selectedFlockId = 'flock-101';
  String? _forcedDisease; // For demo testing specific classes

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

  void setImagePath(String path, {String? targetDisease}) {
    _selectedImagePath = path;
    _forcedDisease = targetDisease;
    _lightingPassed = true;
    _sharpnessPassed = true;
    _singleDroppingPassed = true;
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
    _analysisStep = 'Normalizing image tensor (224x224)...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 350));
    _analysisStep = 'Evaluating MobileNetV3 deep learning weights...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    _analysisStep = 'Synthesizing flock triage signals & clinical rules...';
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
    if (record.prediction.predictedClass != null && record.prediction.severity != null) {
      _lastTreatment = await _diseaseRepo.getTreatment(
        record.prediction.predictedClass!,
        record.prediction.severity!,
      );
    }

    _isAnalyzing = false;
    _analysisStep = 'Complete';
    notifyListeners();
    return record;
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
