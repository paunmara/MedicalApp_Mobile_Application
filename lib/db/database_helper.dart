import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'medicalapp.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        is_admin INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE observations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        profession TEXT NOT NULL,
        section TEXT NOT NULL,
        salon TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE live_checks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        observation_id INTEGER NOT NULL,
        apa_curenta TEXT NOT NULL,
        sapun_lichid TEXT NOT NULL,
        prosop_hartie TEXT NOT NULL,
        dezinfectant TEXT NOT NULL,
        pictograme TEXT NOT NULL,
        pregatire_maini TEXT NOT NULL,
        FOREIGN KEY (observation_id) REFERENCES observations (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE final_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        observation_id INTEGER NOT NULL,
        step_number INTEGER NOT NULL,
        is_mandatory INTEGER NOT NULL,
        method TEXT,
        rating TEXT,
        FOREIGN KEY (observation_id) REFERENCES observations (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE handwash_surveys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        step1 INTEGER NOT NULL,
        step2 INTEGER NOT NULL,
        step3 INTEGER NOT NULL,
        step4 INTEGER NOT NULL,
        step5 INTEGER NOT NULL,
        step6 INTEGER NOT NULL,
        step7 INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // ---------------- Users ----------------

  Future<bool> adminExists() async {
    final db = await database;
    final result = await db.query('users', where: 'is_admin = 1', limit: 1);
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> createUser({
    required String username,
    required String passwordHash,
    bool isAdmin = false,
  }) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'password_hash': passwordHash,
      'is_admin': isAdmin ? 1 : 0,
    });
  }

  // ---------------- Observations (page 1/2/3) ----------------

  Future<int> createObservation({
    required int userId,
    required String date,
    required String profession,
    required String section,
    required String salon,
  }) async {
    final db = await database;
    return await db.insert('observations', {
      'user_id': userId,
      'date': date,
      'profession': profession,
      'section': section,
      'salon': salon,
    });
  }

  Future<int> createLiveCheck({
    required int observationId,
    required String apaCurenta,
    required String sapunLichid,
    required String prosopHartie,
    required String dezinfectant,
    required String pictograme,
    required String pregatireMaini,
  }) async {
    final db = await database;
    return await db.insert('live_checks', {
      'observation_id': observationId,
      'apa_curenta': apaCurenta,
      'sapun_lichid': sapunLichid,
      'prosop_hartie': prosopHartie,
      'dezinfectant': dezinfectant,
      'pictograme': pictograme,
      'pregatire_maini': pregatireMaini,
    });
  }

  Future<void> createFinalStep({
    required int observationId,
    required int stepNumber,
    required bool isMandatory,
    String? method,
    String? rating,
  }) async {
    final db = await database;
    await db.insert('final_steps', {
      'observation_id': observationId,
      'step_number': stepNumber,
      'is_mandatory': isMandatory ? 1 : 0,
      'method': method,
      'rating': rating,
    });
  }

  // ---------------- Handwash surveys ----------------

  Future<int> createHandwashSurvey({
    required int userId,
    required String date,
    required Map<String, bool> steps,
  }) async {
    final db = await database;
    return await db.insert('handwash_surveys', {
      'user_id': userId,
      'date': date,
      'step1': (steps['step1'] ?? false) ? 1 : 0,
      'step2': (steps['step2'] ?? false) ? 1 : 0,
      'step3': (steps['step3'] ?? false) ? 1 : 0,
      'step4': (steps['step4'] ?? false) ? 1 : 0,
      'step5': (steps['step5'] ?? false) ? 1 : 0,
      'step6': (steps['step6'] ?? false) ? 1 : 0,
      'step7': (steps['step7'] ?? false) ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getHandwashSurveysForUser(int userId) async {
    final db = await database;
    return db.query('handwash_surveys', where: 'user_id = ?', whereArgs: [userId]);
  }

  // ---------------- Page 2 monthly stats ----------------

  Future<List<Map<String, dynamic>>> getPage2Stats({
    required String startDate,
    required String endDate,
    int? userId,
  }) async {
    final db = await database;

    final whereClause = StringBuffer('o.date >= ? AND o.date <= ?');
    final whereArgs = <Object?>[startDate, endDate];

    if (userId != null) {
      whereClause.write(' AND o.user_id = ?');
      whereArgs.add(userId);
    }

    return db.rawQuery('''
      SELECT o.date, o.profession, o.section, o.salon,
             lc.apa_curenta, lc.sapun_lichid, lc.prosop_hartie,
             lc.dezinfectant, lc.pictograme, lc.pregatire_maini
      FROM observations o
      JOIN live_checks lc ON lc.observation_id = o.id
      WHERE $whereClause
      ORDER BY o.date
    ''', whereArgs);
  }

  // ---------------- Page 3 stats ----------------

  Future<int> getObservationCountInRange({
    required String startDate,
    required String endDate,
    int? userId,
  }) async {
    final db = await database;
    final whereClause = StringBuffer('date >= ? AND date <= ?');
    final whereArgs = <Object?>[startDate, endDate];

    if (userId != null) {
      whereClause.write(' AND user_id = ?');
      whereArgs.add(userId);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM observations WHERE $whereClause',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getMandatoryFinalSteps({
    required String startDate,
    required String endDate,
    int? userId,
  }) async {
    final db = await database;
    final whereClause = StringBuffer('fs.is_mandatory = 1 AND o.date >= ? AND o.date <= ?');
    final whereArgs = <Object?>[startDate, endDate];

    if (userId != null) {
      whereClause.write(' AND o.user_id = ?');
      whereArgs.add(userId);
    }

    return db.rawQuery('''
      SELECT fs.step_number, fs.rating
      FROM final_steps fs
      JOIN observations o ON o.id = fs.observation_id
      WHERE $whereClause
    ''', whereArgs);
  }
}