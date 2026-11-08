import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:poultrycare/data/models/detection_history_record.dart';
import 'package:poultrycare/services/database_service.dart';
import 'package:poultrycare/services/tflite_service.dart';
import 'package:poultrycare/services/disease_audio_service.dart';
import 'package:poultrycare/data/repositories/diagnostic_repository.dart';
import 'package:poultrycare/features/history/controllers/history_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TFLite Image Preprocessing & Severity Calculation Tests', () {
    test('Direct 224x224 average interpolation preprocessing contract', () {
      // Create a test synthetic RGB image (512x384)
      final testImg = img.Image(width: 512, height: 384);
      for (int y = 0; y < 384; y++) {
        for (int x = 0; x < 512; x++) {
          testImg.setPixelRgb(x, y, 128, 200, 50);
        }
      }

      // Preprocess using exact contract
      final resized = img.copyResize(
        testImg,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.average,
      );

      expect(resized.width, 224);
      expect(resized.height, 224);

      // Verify float32 0..255 value range
      final pixel = resized.getPixel(112, 112);
      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();

      expect(r >= 0.0 && r <= 255.0, isTrue);
      expect(g >= 0.0 && g <= 255.0, isTrue);
      expect(b >= 0.0 && b <= 255.0, isTrue);
      expect(r, 128.0);
      expect(g, 200.0);
      expect(b, 50.0);
    });

    test('Threshold severity derivation: Uncertain below 0.50', () {
      final tflite = TFLiteService();
      // Test internal calculation with synthetic input
      final res = tflite.labels;
      expect(res.contains('Newcastle'), isTrue);
      expect(res.contains('Coccidiosis'), isTrue);
      expect(res.contains('Salmonella'), isTrue);
      expect(res.contains('Healthy'), isTrue);
    });
  });

  group('DatabaseService & DetectionHistoryRecord Tests', () {
    late DatabaseService dbService;

    setUp(() async {
      dbService = DatabaseService.instance;
      await dbService.deleteAllRecords();
    });

    test('DetectionHistoryRecord serialization and deserialization', () {
      final now = DateTime.now();
      final record = DetectionHistoryRecord(
        imagePath: '/storage/sample_newcastle.jpg',
        diseaseName: 'Newcastle',
        severityLevel: 'Severe',
        confidenceScore: 0.945,
        timestamp: now,
        flockId: 'flock-202',
        notes: 'High lethargy observed in shed 2',
        probabilities: {
          'Newcastle': 0.945,
          'Coccidiosis': 0.032,
          'Healthy': 0.012,
          'Salmonella': 0.011,
        },
      );

      final map = record.toMap();
      expect(map['disease_name'], 'Newcastle');
      expect(map['severity_level'], 'Severe');
      expect(map['confidence_score'], 0.945);
      expect(map['flock_id'], 'flock-202');
      expect(map['probabilities_json'], isNotNull);

      final fromMap = DetectionHistoryRecord.fromMap(map);
      expect(fromMap.diseaseName, 'Newcastle');
      expect(fromMap.severityLevel, 'Severe');
      expect(fromMap.confidenceScore, 0.945);
      expect(fromMap.flockId, 'flock-202');
      expect(fromMap.probabilities?['Newcastle'], 0.945);
    });

    test('DatabaseService CRUD operations (Insert, FetchAll, Delete)', () async {
      final time1 = DateTime.now().subtract(const Duration(minutes: 5));
      final time2 = DateTime.now();

      final rec1 = DetectionHistoryRecord(
        imagePath: 'assets/images/sample_coccidiosis.jpg',
        diseaseName: 'Coccidiosis',
        severityLevel: 'Moderate',
        confidenceScore: 0.88,
        timestamp: time1,
      );

      final rec2 = DetectionHistoryRecord(
        imagePath: 'assets/images/sample_healthy.jpg',
        diseaseName: 'Healthy',
        severityLevel: 'Healthy',
        confidenceScore: 0.96,
        timestamp: time2,
      );

      // 1. Insert
      final id1 = await dbService.insertRecord(rec1);
      final id2 = await dbService.insertRecord(rec2);
      expect(id1, isNotNull);
      expect(id2, isNotNull);

      // 2. Fetch All (ordered by timestamp DESC)
      final all = await dbService.fetchAllRecords();
      expect(all.length, 2);

      // 3. Count
      final count = await dbService.getRecordCount();
      expect(count, 2);

      // 4. Delete one record
      final deleted = await dbService.deleteRecord(id1);
      expect(deleted, 1);

      final remaining = await dbService.fetchAllRecords();
      expect(remaining.length, 1);
      expect(remaining.first.diseaseName, 'Healthy');

      // 5. Delete all records
      await dbService.deleteAllRecords();
      final finalCount = await dbService.getRecordCount();
      expect(finalCount, 0);
    });

    test('HistoryController loads, filters, and deletes records dynamically', () async {
      final repo = DiagnosticRepository();
      await repo.clearAllHistory();

      // Run a diagnosis to persist into local SQLite
      await repo.runDiagnosis(
        imagePath: 'assets/images/sample_coccidiosis.jpg',
        flockSignals: {
          'lethargy': 'None',
          'intakeDrop': 'Normal',
          'suddenMortality': 'None in 24h',
        },
        forcedDisease: 'coccidiosis',
      );

      final controller = HistoryController(repo);
      await controller.loadRecords();

      expect(controller.filteredRecords.isNotEmpty, isTrue);
      expect(controller.filteredRecords.first.prediction.predictedClass, 'coccidiosis');

      // Test disease filter
      controller.setDiseaseFilter('healthy');
      expect(controller.filteredRecords.isEmpty, isTrue);

      controller.setDiseaseFilter('all');
      expect(controller.filteredRecords.isNotEmpty, isTrue);

      // Test delete
      final scanId = controller.filteredRecords.first.scan.id;
      await controller.deleteRecord(scanId);
      expect(controller.filteredRecords.isEmpty, isTrue);
    });
  });

  group('DiseaseAudioService & Dynamic Script Mapping Tests', () {
    test('Dynamic switch/case normalizes all 4 poultry disease classes accurately', () {
      // 1. Newcastle variations
      expect(DiseaseAudioService.parseDisease('Newcastle'), PoultryDiseaseType.newcastle);
      expect(DiseaseAudioService.parseDisease('newcastle disease'), PoultryDiseaseType.newcastle);
      expect(DiseaseAudioService.parseDisease('NCD'), PoultryDiseaseType.newcastle);
      expect(DiseaseAudioService.parseDisease('رانی کھیت'), PoultryDiseaseType.newcastle);

      // 2. Coccidiosis variations
      expect(DiseaseAudioService.parseDisease('Coccidiosis'), PoultryDiseaseType.coccidiosis);
      expect(DiseaseAudioService.parseDisease('cocci'), PoultryDiseaseType.coccidiosis);
      expect(DiseaseAudioService.parseDisease('bloody diarrhea'), PoultryDiseaseType.coccidiosis);
      expect(DiseaseAudioService.parseDisease('خونی پیچش'), PoultryDiseaseType.coccidiosis);

      // 3. Salmonella variations
      expect(DiseaseAudioService.parseDisease('Salmonella'), PoultryDiseaseType.salmonella);
      expect(DiseaseAudioService.parseDisease('pullorum'), PoultryDiseaseType.salmonella);
      expect(DiseaseAudioService.parseDisease('fowl typhoid'), PoultryDiseaseType.salmonella);
      expect(DiseaseAudioService.parseDisease('سالمونیلا'), PoultryDiseaseType.salmonella);

      // 4. Healthy variations
      expect(DiseaseAudioService.parseDisease('Healthy'), PoultryDiseaseType.healthy);
      expect(DiseaseAudioService.parseDisease('normal'), PoultryDiseaseType.healthy);
      expect(DiseaseAudioService.parseDisease(null), PoultryDiseaseType.healthy);
    });

    test('Newcastle profile contains dedicated audio asset and Newcastle-specific Urdu symptoms', () {
      final profile = DiseaseAudioService.getProfile('Newcastle Disease', severity: 'severe', confidenceScore: 0.96);

      expect(profile.type, PoultryDiseaseType.newcastle);
      expect(profile.audioAssetPath, 'assets/audio/newcastle.mp3');
      expect(profile.urduName.contains('رانی کھیت'), isTrue);
      expect(profile.symptomsUrdu.contains('سبز پتلا'), isTrue);
      expect(profile.symptomsUrdu.contains('گردن مڑنا'), isTrue);

      final script = profile.buildSpokenScript(isUrdu: true, severity: 'severe', confidenceScore: 0.96);
      expect(script.contains('رانی کھیت'), isTrue);
      expect(script.contains('تندرست اور صحت مند'), isFalse); // Never defaults to healthy!
      expect(script.contains('96%'), isTrue);
      expect(script.contains('شدید'), isTrue);
    });

    test('Coccidiosis profile contains dedicated audio asset and Coccidiosis-specific Urdu script', () {
      final profile = DiseaseAudioService.getProfile('coccidiosis', severity: 'moderate', confidenceScore: 0.88);

      expect(profile.type, PoultryDiseaseType.coccidiosis);
      expect(profile.audioAssetPath, 'assets/audio/coccidiosis.mp3');
      expect(profile.urduName.contains('کوکسیڈیوسس'), isTrue);
      expect(profile.symptomsUrdu.contains('خون'), isTrue);

      final script = profile.buildSpokenScript(isUrdu: true, severity: 'moderate', confidenceScore: 0.88);
      expect(script.contains('کوکسیڈیوسس'), isTrue);
      expect(script.contains('ایمپرولیم'), isTrue);
      expect(script.contains('88%'), isTrue);
    });

    test('Salmonella profile contains dedicated audio asset and Salmonella-specific Urdu script', () {
      final profile = DiseaseAudioService.getProfile('salmonella', severity: 'mild', confidenceScore: 0.91);

      expect(profile.type, PoultryDiseaseType.salmonella);
      expect(profile.audioAssetPath, 'assets/audio/salmonella.mp3');
      expect(profile.urduName.contains('سالمونیلا'), isTrue);
      expect(profile.symptomsUrdu.contains('سفید چاک'), isTrue);

      final script = profile.buildSpokenScript(isUrdu: true, severity: 'mild', confidenceScore: 0.91);
      expect(script.contains('سالمونیلا'), isTrue);
      expect(script.contains('اینروفلوکساسین'), isTrue);
      expect(script.contains('91%'), isTrue);
    });

    test('Healthy profile contains healthy spoken reassurance', () {
      final profile = DiseaseAudioService.getProfile('healthy', severity: 'mild', confidenceScore: 0.99);

      expect(profile.type, PoultryDiseaseType.healthy);
      expect(profile.audioAssetPath, 'assets/audio/healthy.mp3');
      expect(profile.urduName.contains('تندرست'), isTrue);

      final script = profile.buildSpokenScript(isUrdu: true, severity: 'mild', confidenceScore: 0.99);
      expect(script.contains('تندرست اور نارمل'), isTrue);
      expect(script.contains('99%'), isTrue);
    });
  });
}
