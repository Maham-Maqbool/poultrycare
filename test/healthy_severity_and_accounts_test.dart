import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poultrycare/data/models/detection_history_record.dart';
import 'package:poultrycare/data/repositories/auth_repository.dart';
import 'package:poultrycare/data/repositories/diagnostic_repository.dart';
import 'package:poultrycare/data/repositories/flock_repository.dart';
import 'package:poultrycare/services/database_service.dart';
import 'package:poultrycare/services/session_service.dart';
import 'fake_tflite_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Problem 1 & 2: Healthy Severity & Triage Rules', () {
    test('Problem 1: Healthy result is NEVER changed by sudden mortality or flock answers', () async {
      final repo = DiagnosticRepository(
        tfliteService: FakeTFLiteService(predictedClass: 'healthy', severity: 'healthy'),
      );

      final record = await repo.runDiagnosis(
        imagePath: 'assets/images/samples/healthy.png',
        flockSignals: {
          'lethargy': 'Over 10% of birds',
          'intakeDrop': 'Severely reduced (>30%)',
          'suddenMortality': 'Multiple birds died',
        },
      );

      expect(record.prediction.predictedClass, 'healthy');
      expect(record.prediction.severity, 'healthy');
      expect(record.prediction.urgency, 'monitor');
    });

    test('Problem 2: Stored Healthy record reconstruction preserves healthy severity (not mild)', () async {
      final dbService = DatabaseService.instance;
      final rec = DetectionHistoryRecord(
        userId: 'usr-001',
        imagePath: 'assets/images/samples/healthy.png',
        diseaseName: 'healthy',
        severityLevel: 'healthy',
        confidenceScore: 0.98,
        timestamp: DateTime.now(),
      );

      await dbService.insertRecord(rec);

      final repo = DiagnosticRepository();
      final records = await repo.getAllRecords(userId: 'usr-001');

      final healthyScan = records.firstWhere((r) => r.prediction.predictedClass == 'healthy');
      expect(healthyScan.prediction.severity, 'healthy');
      expect(healthyScan.prediction.urgency, 'monitor');
    });
  });

  group('Problem 3 & 4: Registered Users & Per-Account Scoped Data', () {
    test('Problem 3: Registration persists user credentials and allows repeated logins', () async {
      final authRepo = AuthRepository();

      // Register new user
      final user = await authRepo.register(
        name: 'Ahmed Farmer',
        identifier: 'ahmed@poultrycare.farm',
        password: 'securePassword123',
        consent: true,
      );

      expect(user.displayName, 'Ahmed Farmer');
      expect(user.email, 'ahmed@poultrycare.farm');

      // Logout
      await authRepo.logout();
      expect(authRepo.currentUser.isGuest, isTrue);

      // Wrong password test
      expect(
        () async => await authRepo.login(
          identifier: 'ahmed@poultrycare.farm',
          password: 'wrongPassword',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Incorrect password'),
        )),
      );

      // Correct password test
      final loggedInUser = await authRepo.login(
        identifier: 'ahmed@poultrycare.farm',
        password: 'securePassword123',
      );

      expect(loggedInUser.id, user.id);
      expect(loggedInUser.displayName, 'Ahmed Farmer');
    });

    test('Problem 3: Demo account login still succeeds with standard demo credentials', () async {
      final authRepo = AuthRepository();
      final demoUser = await authRepo.login(
        identifier: 'farmer@poultrycare.farm',
        password: 'password123',
      );

      expect(demoUser.id, 'usr-001');
      expect(demoUser.email, 'farmer@poultrycare.farm');
    });

    test('Problem 4: Guest sessions use fixed id guest', () async {
      final authRepo = AuthRepository();
      final guest1 = await authRepo.continueAsGuest();
      expect(guest1.id, 'guest');

      await authRepo.logout();

      final guest2 = await authRepo.continueAsGuest();
      expect(guest2.id, 'guest');
    });

    test('Problem 4: Data is strictly scoped per account', () async {
      final session = SessionService.instance;
      final flockRepo = FlockRepository();
      final diagRepo = DiagnosticRepository(
        tfliteService: FakeTFLiteService(predictedClass: 'coccidiosis', severity: 'moderate'),
      );

      // User A creates a flock and scan
      await session.saveUserSession(id: 'usr-user-A', name: 'User A');
      await flockRepo.addFlock(name: 'Shed Alpha', birdCount: 500, userId: 'usr-user-A');
      await diagRepo.runDiagnosis(
        imagePath: 'assets/images/samples/coccidiosis.jpg',
        flockSignals: {'lethargy': 'None', 'intakeDrop': 'Normal', 'suddenMortality': 'None in 24h'},
      );

      // Verify User A sees 1 flock and at least 1 scan
      final userAFlocks = await flockRepo.getFlocks(userId: 'usr-user-A');
      final userAScans = await diagRepo.getAllRecords(userId: 'usr-user-A');
      expect(userAFlocks.any((f) => f.name == 'Shed Alpha'), isTrue);
      expect(userAScans.any((s) => s.scan.userId == 'usr-user-A'), isTrue);

      // User B logs in
      await session.saveUserSession(id: 'usr-user-B', name: 'User B');
      final userBFlocks = await flockRepo.getFlocks(userId: 'usr-user-B');
      final userBScans = await diagRepo.getAllRecords(userId: 'usr-user-B');

      // User B should NOT see User A's data
      expect(userBFlocks.any((f) => f.name == 'Shed Alpha'), isFalse);
      expect(userBScans.any((s) => s.scan.userId == 'usr-user-A'), isFalse);
    });
  });
}
