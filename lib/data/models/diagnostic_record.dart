import 'scan_model.dart';
import 'prediction_model.dart';
import 'feedback_model.dart';

/// DiagnosticRecord aggregates the scan metadata, AI prediction output,
/// and optional post-consultation field feedback.
class DiagnosticRecord {
  final ScanModel scan;
  final PredictionModel prediction;
  final FeedbackModel? feedback;

  const DiagnosticRecord({
    required this.scan,
    required this.prediction,
    this.feedback,
  });
}

