import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poultrycare/core/widgets/status_badge.dart';
import 'package:poultrycare/data/models/flock_model.dart';
import 'package:poultrycare/data/models/scan_model.dart';
import 'package:poultrycare/data/models/prediction_model.dart';
import 'package:poultrycare/data/models/diagnostic_record.dart';
import 'package:poultrycare/data/repositories/auth_repository.dart';
import 'package:poultrycare/data/repositories/diagnostic_repository.dart';
import 'package:poultrycare/core/utils/flock_status_helper.dart';
import 'package:poultrycare/features/profile/controllers/settings_controller.dart';
import 'package:poultrycare/services/disease_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Addendum 9 Verification Tests', () {
    test('C1: Newcastle alias (ncd / newcastle) maps to VET NOW urgency', () async {
      final repo = DiagnosticRepository();

      // Test with forcedDisease = 'ncd'
      final recordNcd = await repo.runDiagnosis(
        imagePath: 'assets/images/samples/newcastle.jpg',
        flockSignals: {'lethargy': 'None', 'intakeDrop': 'Normal', 'suddenMortality': 'None in 24h'},
        forcedDisease: 'ncd',
      );

      expect(recordNcd.prediction.predictedClass, 'newcastle');
      expect(recordNcd.prediction.urgency, 'vet_now');

      // Test with forcedDisease = 'newcastle'
      final recordNewcastle = await repo.runDiagnosis(
        imagePath: 'assets/images/samples/newcastle.jpg',
        flockSignals: {'lethargy': 'None', 'intakeDrop': 'Normal', 'suddenMortality': 'None in 24h'},
        forcedDisease: 'newcastle',
      );

      expect(recordNewcastle.prediction.predictedClass, 'newcastle');
      expect(recordNewcastle.prediction.urgency, 'vet_now');
    });

    test('C2 & Minor 5: Newcastle audio profile has no antibiotics, supportive care only, and Urdu greeting', () {
      final profile = DiseaseAudioService.getProfile('newcastle');
      expect(profile.treatmentUrdu.contains('کوئی خاص علاج نہیں'), isTrue);
      expect(profile.treatmentEn.contains('no specific treatment'), isTrue);
      expect(profile.treatmentUrdu.contains('اینٹی بائیوٹک'), isFalse);
      expect(profile.treatmentEn.contains('antibiotic'), isFalse);

      expect(profile.baseTtsUrdu.contains('محترم کسان'), isTrue);
      expect(profile.baseTtsUrdu.contains('محترم فارمر'), isFalse);
    });

    test('M1: StatusBadge supports uncertain severity and retake_photo urgency', () {
      final sevBadge = StatusBadge.forSeverity('uncertain');
      expect(sevBadge.label, 'Uncertain (Retest)');

      final urgBadge = StatusBadge.forUrgency('retake_photo');
      expect(urgBadge.label, 'Retake Photo');
    });

    test('M4: AuthRepository validates passwords and rejects unknown accounts', () async {
      final repo = AuthRepository();

      // Unknown account
      expect(
        () => repo.login(identifier: 'unknown@test.com', password: 'password123'),
        throwsA(isA<Exception>()),
      );

      // Wrong password
      expect(
        () => repo.login(identifier: 'farmer@poultrycare.farm', password: 'wrongpassword'),
        throwsA(isA<Exception>()),
      );

      // Correct credentials
      final user = await repo.login(identifier: 'farmer@poultrycare.farm', password: 'password123');
      expect(user.email, 'farmer@poultrycare.farm');
    });

    test('Minor 1: FlockStatusHelper evaluates risk strictly for Moderate or Severe scans within 30 days', () {
      final now = DateTime.now();
      final flock = FlockModel(
        id: 'flock-test-1',
        userId: 'usr-1',
        name: 'Shed 1',
        birdCount: 100,
        createdAt: now,
      );

      final mildScan = DiagnosticRecord(
        scan: ScanModel(
          id: 's1',
          deviceId: 'dev1',
          flockId: 'flock-test-1',
          idempotencyKey: 'k1',
          imagePath: 'path1',
          createdAt: now,
        ),
        prediction: PredictionModel(
          id: 'p1',
          scanId: 's1',
          predictedClass: 'coccidiosis',
          severity: 'mild',
          urgency: 'treat_today',
          createdAt: now,
        ),
      );

      expect(FlockStatusHelper.isAtRisk(flock: flock, records: [mildScan]), isFalse);

      final severeScan = DiagnosticRecord(
        scan: ScanModel(
          id: 's2',
          deviceId: 'dev1',
          flockId: 'flock-test-1',
          idempotencyKey: 'k2',
          imagePath: 'path2',
          createdAt: now,
        ),
        prediction: PredictionModel(
          id: 'p2',
          scanId: 's2',
          predictedClass: 'coccidiosis',
          severity: 'severe',
          urgency: 'vet_now',
          createdAt: now,
        ),
      );

      expect(FlockStatusHelper.isAtRisk(flock: flock, records: [severeScan]), isTrue);
    });

    test('Minor 11: SettingsController validates 10-11 digit phone numbers', () async {
      final settings = SettingsController();

      // Too short
      expect(await settings.saveVetPhone('12345'), isFalse);

      // Alphabetic characters
      expect(await settings.saveVetPhone('0300abcdefg'), isFalse);

      // Valid 11-digit local format
      expect(await settings.saveVetPhone('03001234567'), isTrue);

      // Valid +92 international format
      expect(await settings.saveVetPhone('+923001234567'), isTrue);
    });
  });
}
