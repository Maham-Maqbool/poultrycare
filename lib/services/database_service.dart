import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/detection_history_record.dart';
import '../data/models/flock_model.dart';

/// DatabaseService manages the local SQLite database for offline diagnostic history
/// and farmer-managed flocks/sheds.
class DatabaseService {
  static const String _databaseName = 'poultrycare_history.db';
  static const int _databaseVersion = 2;
  static const String tableHistory = 'detection_history';
  static const String tableFlocks = 'flocks';

  // Singleton instance
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();
  factory DatabaseService() => instance;

  static Database? _database;
  final List<DetectionHistoryRecord> _memoryFallback = [];
  final List<FlockModel> _flocksMemoryFallback = [];

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
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await _ensureTables(db);
      },
    );
  }

  /// Creates tables and indexes during database creation.
  /// Fresh installs start with ZERO records (no fake/demo seeds).
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

    await db.execute('''
      CREATE TABLE $tableFlocks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        bird_count INTEGER,
        breed TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        active_disease_count INTEGER DEFAULT 0
      )
    ''');
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableFlocks (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          bird_count INTEGER,
          breed TEXT,
          notes TEXT,
          created_at TEXT NOT NULL,
          active_disease_count INTEGER DEFAULT 0
        )
      ''');
    }
  }

  Future<void> _ensureTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableFlocks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        bird_count INTEGER,
        breed TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        active_disease_count INTEGER DEFAULT 0
      )
    ''');
  }

  // ==========================================
  // DETECTION HISTORY CRUD
  // ==========================================

  /// Inserts a new detection record into the local SQLite database.
  /// Returns the generated primary key id.
  Future<int> insertRecord(DetectionHistoryRecord record) async {
    try {
      final db = await database;
      final id = await db.insert(
        tableHistory,
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (record.flockId != null && record.flockId!.isNotEmpty) {
        await recalculateFlockRisk(record.flockId!);
      }
      return id;
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite insert error: $e');
      final fallbackId = _memoryFallback.length + 1;
      _memoryFallback.insert(0, record.copyWith(id: fallbackId));
      if (record.flockId != null && record.flockId!.isNotEmpty) {
        await recalculateFlockRisk(record.flockId!);
      }
      return fallbackId;
    }
  }

  /// Fetches all detection history records sorted by timestamp descending.
  /// Empty table stays empty with no automatic re-seeding.
  Future<List<DetectionHistoryRecord>> fetchAllRecords() async {
    try {
      final db = await database;
      final maps = await db.query(
        tableHistory,
        orderBy: 'timestamp DESC',
      );
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
      // Query flockId prior to deletion to recalculate risk
      final rec = await getRecordById(id);
      final flockId = rec?.flockId;

      final result = await db.delete(
        tableHistory,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (flockId != null && flockId.isNotEmpty) {
        await recalculateFlockRisk(flockId);
      }
      return result;
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite delete error: $e');
      final rec = _memoryFallback.where((r) => r.id == id).firstOrNull;
      final flockId = rec?.flockId;
      final initialLen = _memoryFallback.length;
      _memoryFallback.removeWhere((r) => r.id == id);
      if (flockId != null && flockId.isNotEmpty) {
        await recalculateFlockRisk(flockId);
      }
      return initialLen - _memoryFallback.length;
    }
  }

  /// Deletes all detection records from the local history table.
  /// Returns the number of affected rows.
  Future<int> deleteAllRecords() async {
    try {
      final db = await database;
      final count = await db.delete(tableHistory);
      await db.update(tableFlocks, {'active_disease_count': 0});
      for (int i = 0; i < _flocksMemoryFallback.length; i++) {
        _flocksMemoryFallback[i] = _flocksMemoryFallback[i].copyWith(activeDiseaseCount: 0);
      }
      return count;
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite clear error: $e');
      final count = _memoryFallback.length;
      _memoryFallback.clear();
      for (int i = 0; i < _flocksMemoryFallback.length; i++) {
        _flocksMemoryFallback[i] = _flocksMemoryFallback[i].copyWith(activeDiseaseCount: 0);
      }
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

  // ==========================================
  // FLOCKS & SHEDS PERSISTENT CRUD
  // ==========================================

  Map<String, dynamic> _flockToDbMap(FlockModel flock) => {
    'id': flock.id,
    'user_id': flock.userId,
    'name': flock.name,
    'bird_count': flock.birdCount,
    'breed': flock.breed,
    'notes': flock.notes,
    'created_at': flock.createdAt.toIso8601String(),
    'active_disease_count': flock.activeDiseaseCount,
  };

  FlockModel _flockFromDbMap(Map<String, dynamic> map) => FlockModel(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    name: map['name'] as String,
    birdCount: map['bird_count'] as int?,
    breed: map['breed'] as String?,
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    activeDiseaseCount: map['active_disease_count'] as int? ?? 0,
  );

  /// Fetches all flocks stored in the local database.
  Future<List<FlockModel>> fetchAllFlocks() async {
    try {
      await syncAllFlocksRisk();
      final db = await database;
      final maps = await db.query(
        tableFlocks,
        orderBy: 'created_at DESC',
      );
      return maps.map(_flockFromDbMap).toList();
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite query flocks error: $e');
      return List.unmodifiable(_flocksMemoryFallback);
    }
  }

  /// Fetches a flock by its unique ID.
  Future<FlockModel?> getFlockById(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableFlocks,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return _flockFromDbMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite getFlockById error: $e');
      try {
        return _flocksMemoryFallback.firstWhere((f) => f.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// Inserts a new flock into the database.
  Future<void> insertFlock(FlockModel flock) async {
    try {
      final db = await database;
      await db.insert(
        tableFlocks,
        _flockToDbMap(flock),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite insert flock error: $e');
      _flocksMemoryFallback.insert(0, flock);
    }
  }

  /// Updates an existing flock in the database.
  Future<FlockModel> updateFlock(FlockModel flock) async {
    try {
      final db = await database;
      await db.update(
        tableFlocks,
        _flockToDbMap(flock),
        where: 'id = ?',
        whereArgs: [flock.id],
      );
      return flock;
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite update flock error: $e');
      final idx = _flocksMemoryFallback.indexWhere((f) => f.id == flock.id);
      if (idx != -1) {
        _flocksMemoryFallback[idx] = flock;
      }
      return flock;
    }
  }

  /// Deletes a flock by ID.
  Future<void> deleteFlock(String id) async {
    try {
      final db = await database;
      await db.delete(
        tableFlocks,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite delete flock error: $e');
      _flocksMemoryFallback.removeWhere((f) => f.id == id);
    }
  }

  /// Deletes all flocks.
  Future<void> deleteAllFlocks() async {
    try {
      final db = await database;
      await db.delete(tableFlocks);
    } catch (e) {
      debugPrint('[DatabaseService] Native SQLite deleteAllFlocks error: $e');
      _flocksMemoryFallback.clear();
    }
  }

  /// Recalculates the active disease count for a specific flock based on
  /// scans within the last 30 days and updates the flocks table.
  Future<void> recalculateFlockRisk(String flockId) async {
    try {
      final db = await database;
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
      final scans = await db.query(
        tableHistory,
        where: 'flock_id = ? AND timestamp >= ?',
        whereArgs: [flockId, thirtyDaysAgo],
      );

      int activeCount = 0;
      for (final s in scans) {
        final disease = (s['disease_name'] as String? ?? '').toLowerCase();
        final severity = (s['severity_level'] as String? ?? '').toLowerCase();
        if (disease != 'healthy') {
          if (severity == 'severe' || severity == 'moderate') {
            activeCount++;
          }
        }
      }

      await db.update(
        tableFlocks,
        {'active_disease_count': activeCount},
        where: 'id = ?',
        whereArgs: [flockId],
      );

      final idx = _flocksMemoryFallback.indexWhere((f) => f.id == flockId);
      if (idx != -1) {
        final current = _flocksMemoryFallback[idx];
        _flocksMemoryFallback[idx] = current.copyWith(activeDiseaseCount: activeCount);
      }
    } catch (e) {
      debugPrint('[DatabaseService] recalculateFlockRisk error: $e');
    }
  }

  /// Synchronizes active risk status for all flocks in the database.
  Future<void> syncAllFlocksRisk() async {
    try {
      final db = await database;
      final flocks = await db.query(tableFlocks, columns: ['id']);
      for (final f in flocks) {
        final fid = f['id'] as String?;
        if (fid != null && fid.isNotEmpty) {
          await recalculateFlockRisk(fid);
        }
      }
    } catch (e) {
      debugPrint('[DatabaseService] syncAllFlocksRisk error: $e');
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

