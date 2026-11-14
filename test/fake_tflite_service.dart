import 'package:poultrycare/services/tflite_service.dart';

class FakeTFLiteService extends TFLiteService {
  final String predictedClass;
  final String severity;
  final double confidence;

  FakeTFLiteService({
    required this.predictedClass,
    this.severity = 'moderate',
    this.confidence = 0.94,
  });

  @override
  Future<TFLiteDiagnosisResult> diagnoseImage(String imagePath) async {
    return TFLiteDiagnosisResult(
      predictedClass: predictedClass,
      confidence: confidence,
      severity: severity,
      urgency: (predictedClass.toLowerCase() == 'newcastle' || severity == 'severe')
          ? 'vet_now'
          : (predictedClass.toLowerCase() == 'healthy' ? 'monitor' : 'treat_today'),
      probabilities: {predictedClass: confidence},
      preprocessMs: 10,
      inferenceMs: 20,
      totalMs: 30,
      modelName: 'PC-VisionAI-v2.4',
      isUncertain: severity == 'uncertain',
      rawImageWidth: 640,
      rawImageHeight: 480,
    );
  }
}
