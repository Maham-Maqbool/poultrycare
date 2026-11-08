import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants/app_assets.dart';
import '../data/models/detection_history_record.dart';

/// DatabaseService manages the local SQLite database for offline diagnostic history.
class DatabaseService {
  static const String _databaseName = 'poultrycare_history.db';
  static const int _databaseVersion = 1;
  static const String tableHistory = 'detection_history';

  // Singleton instance
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();
  factory DatabaseService() => instance;

  static Database? _database;
  static bool _hasExplicitlyCleared = false;
  final List<DetectionHistoryRecord> _memoryFallback = [];

  /// Returns the singleton Database instance, initializing if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database file on device storage.
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Creates tables and indexes during database creation, seeding initial farm scans.
  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        disease_name TEXT NOT NULL,
        severity_level TEXT NOT NULL,
        confidence_score REAL NOT NULL,
        timestamp TEXT NOT NULL,
        flock_id TEXT,
        notes TEXT,
        probabilities_json TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_detection_timestamp ON $tableHistory (timestamp DESC)',
    );

    // Seed realistic initial farm screening records so fresh installs have data
    final initialRecords = [
      DetectionHistoryRecord(
        imagePath: AppAssets.sampleCoccidiosis,
        diseaseName: 'Coccidiosis',
        severityLevel: 'Moderate',
        confidenceScore: 0.94,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        flockId: 'flock-101',
        notes: 'Reddish mucoid dropping in Broiler Batch 26',
        probabilities: {'coccidiosis': 0.94, 'healthy': 0.03, 'newcastle': 0.02, 'salmonella': 0.01},
      ),
      DetectionHistoryRecord(
        imagePath: AppAssets.sampleHealthy,
        diseaseName: 'Healthy',
        severityLevel: 'Healthy',
        confidenceScore: 0.98,
        timestamp: DateTime.now().subtract(const Duration(hours: 14)),
        flockId: 'flock-102',
        notes: 'Normal digestive dropping in Layer House A',
        probabilities: {'healthy': 0.98, 'coccidiosis': 0.01, 'newcastle': 0.005, 'salmonella': 0.005},
      ),
      DetectionHistoryRecord(
        imagePath: AppAssets.sampleNewcastle,
        diseaseName: 'Newcastle',
        severityLevel: 'Severe',
        confidenceScore: 0.96,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        flockId: 'flock-103',
        notes: 'Green watery dropping with lethargy alert',
        probabilities: {'newcastle': 0.96, 'coccidiosis': 0.02, 'salmonella': 0.015, 'healthy': 0.005},
      ),
    ];

    for (final rec in initialRecords) {
      await db.insert(tableHistory, rec.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Inserts a new detection record into the local SQLite database.
  /// Returns the generated primary key id.
  Future<int> insertRecord(DetectionHistoryRecord record) async {
    _hasExplicitlyCleared = false;
    try {
      final db = await database;
      final id = await db.insert(
        tableHistory,
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite insert error: $e');
      final fallbackId = _memoryFallback.length + 1;
      _memoryFallback.insert(0, record.copyWith(id: fallbackId));
      return fallbackId;
    }
  }

  /// Fetches all detection history records sorted by timestamp descending.
  Future<List<DetectionHistoryRecord>> fetchAllRecords() async {
    try {
      final db = await database;
      var maps = await db.query(
        tableHistory,
        orderBy: 'timestamp DESC',
      );
      if (maps.isEmpty && !_hasExplicitlyCleared) {
        final initialRecords = [
          DetectionHistoryRecord(
            imagePath: AppAssets.sampleCoccidiosis,
            diseaseName: 'Coccidiosis',
            severityLevel: 'Moderate',
            confidenceScore: 0.94,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            flockId: 'flock-101',
            notes: 'Reddish mucoid dropping in Broiler Batch 26',
            probabilities: {'coccidiosis': 0.94, 'healthy': 0.03, 'newcastle': 0.02, 'salmonella': 0.01},
          ),
          DetectionHistoryRecord(
            imagePath: AppAssets.sampleHealthy,
            diseaseName: 'Healthy',
            severityLevel: 'Healthy',
            confidenceScore: 0.98,
            timestamp: DateTime.now().subtract(const Duration(hours: 14)),
            flockId: 'flock-102',
            notes: 'Normal digestive dropping in Layer House A',
            probabilities: {'healthy': 0.98, 'coccidiosis': 0.01, 'newcastle': 0.005, 'salmonella': 0.005},
          ),
          DetectionHistoryRecord(
            imagePath: AppAssets.sampleNewcastle,
            diseaseName: 'Newcastle',
            severityLevel: 'Severe',
            confidenceScore: 0.96,
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
            flockId: 'flock-103',
            notes: 'Green watery dropping with lethargy alert',
            probabilities: {'newcastle': 0.96, 'coccidiosis': 0.02, 'salmonella': 0.015, 'healthy': 0.005},
          ),
        ];

        for (final rec in initialRecords) {
          await db.insert(tableHistory, rec.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
        maps = await db.query(tableHistory, orderBy: 'timestamp DESC');
      }
      return maps.map((m) => DetectionHistoryRecord.fromMap(m)).toList();
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite query error: $e');
      return List.unmodifiable(_memoryFallback);
    }
  }

  /// Fetches a single detection record by its primary key ID.
  Future<DetectionHistoryRecord?> getRecordById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableHistory,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return DetectionHistoryRecord.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite query by id error: $e');
      try {
        return _memoryFallback.firstWhere((r) => r.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// Deletes a specific detection record by its ID.
  /// Returns the number of affected rows.
  Future<int> deleteRecord(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableHistory,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite delete error: $e');
      final initialLen = _memoryFallback.length;
      _memoryFallback.removeWhere((r) => r.id == id);
      return initialLen - _memoryFallback.length;
    }
  }

  /// Deletes all detection records from the local history table.
  /// Returns the number of affected rows.
  Future<int> deleteAllRecords() async {
    _hasExplicitlyCleared = true;
    try {
      final db = await database;
      return await db.delete(tableHistory);
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite clear error: $e');
      final count = _memoryFallback.length;
      _memoryFallback.clear();
      return count;
    }
  }

  /// Returns total count of saved detection records.
  Future<int> getRecordCount() async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableHistory'),
      );
      return count ?? 0;
    } catch (_) {
      return _memoryFallback.length;
    }
  }

  /// Closes database connection.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

