import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitfudge.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender INTEGER NOT NULL,
        heightCm REAL NOT NULL,
        weightKg REAL NOT NULL,
        fitnessGoal INTEGER NOT NULL,
        activityLevel INTEGER NOT NULL,
        unitSystem INTEGER NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_account (
        id INTEGER PRIMARY KEY,
        isLoggedIn INTEGER NOT NULL,
        userId TEXT NOT NULL,
        email TEXT NOT NULL,
        displayName TEXT NOT NULL,
        membershipTier TEXT NOT NULL,
        authProvider TEXT NOT NULL,
        lastLoginTimestamp INTEGER NOT NULL,
        accountCreatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        primaryMuscle TEXT NOT NULL,
        secondaryMuscles TEXT NOT NULL,
        equipment TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        exerciseType TEXT NOT NULL,
        instructions TEXT NOT NULL,
        startingPosition TEXT NOT NULL,
        executionSteps TEXT NOT NULL,
        commonMistakes TEXT NOT NULL,
        formSafetyNotes TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        targetFocus TEXT NOT NULL,
        exerciseIdsJson TEXT NOT NULL,
        notes TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        templateName TEXT NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER NOT NULL,
        durationSeconds INTEGER NOT NULL,
        totalVolumeKg REAL NOT NULL,
        totalSets INTEGER NOT NULL,
        totalReps INTEGER NOT NULL,
        notes TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_set_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        exerciseId TEXT NOT NULL,
        exerciseName TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        weightKg REAL NOT NULL,
        reps INTEGER NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE body_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        weightKg REAL NOT NULL,
        chestCm REAL,
        waistCm REAL,
        armsCm REAL,
        hipsCm REAL,
        thighsCm REAL,
        notes TEXT NOT NULL
      )
    ''');
  }

  // ─── UserProfile ────────────────────────────────────────────────────────────

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final rows = await db.query('user_profile', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── UserAccount ────────────────────────────────────────────────────────────

  Future<UserAccount?> getUserAccount() async {
    final db = await database;
    final rows = await db.query('user_account', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return null;
    return UserAccount.fromMap(rows.first);
  }

  Future<void> saveUserAccount(UserAccount account) async {
    final db = await database;
    await db.insert(
      'user_account',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Exercises ──────────────────────────────────────────────────────────────

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final rows = await db.query('exercises', orderBy: 'name ASC');
    return rows.map(Exercise.fromMap).toList();
  }

  Future<Exercise?> getExerciseById(String id) async {
    final db = await database;
    final rows = await db.query('exercises', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Exercise.fromMap(rows.first);
  }

  Future<void> insertExercises(List<Exercise> exercises) async {
    final db = await database;
    final batch = db.batch();
    for (final e in exercises) {
      batch.insert('exercises', e.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<bool> exercisesSeeded() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM exercises'),
    );
    return (count ?? 0) > 0;
  }

  // ─── WorkoutTemplates ───────────────────────────────────────────────────────

  Future<List<WorkoutTemplate>> getAllTemplates() async {
    final db = await database;
    final rows = await db.query('workout_templates', orderBy: 'createdAt DESC');
    return rows.map(WorkoutTemplate.fromMap).toList();
  }

  Future<int> insertTemplate(WorkoutTemplate template) async {
    final db = await database;
    return db.insert('workout_templates', template.toMap());
  }

  Future<void> updateTemplate(WorkoutTemplate template) async {
    final db = await database;
    await db.update(
      'workout_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<void> deleteTemplate(int id) async {
    final db = await database;
    await db.delete('workout_templates', where: 'id = ?', whereArgs: [id]);
  }

  // ─── WorkoutSessions ────────────────────────────────────────────────────────

  Future<List<WorkoutSession>> getAllSessions() async {
    final db = await database;
    final rows = await db.query('workout_sessions', orderBy: 'startTime DESC');
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<int> insertSession(WorkoutSession session) async {
    final db = await database;
    return db.insert('workout_sessions', session.toMap());
  }

  Future<void> deleteSession(int id) async {
    final db = await database;
    await db.delete('workout_sessions', where: 'id = ?', whereArgs: [id]);
    await db.delete('workout_set_records', where: 'sessionId = ?', whereArgs: [id]);
  }

  // ─── WorkoutSetRecords ──────────────────────────────────────────────────────

  Future<List<WorkoutSetRecord>> getSetRecordsForSession(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'workout_set_records',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'setNumber ASC',
    );
    return rows.map(WorkoutSetRecord.fromMap).toList();
  }

  Future<void> insertSetRecords(List<WorkoutSetRecord> records) async {
    final db = await database;
    final batch = db.batch();
    for (final r in records) {
      batch.insert('workout_set_records', r.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<WorkoutSetRecord>> getSetRecordsForExercise(String exerciseId) async {
    final db = await database;
    final rows = await db.query(
      'workout_set_records',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
      orderBy: 'id DESC',
    );
    return rows.map(WorkoutSetRecord.fromMap).toList();
  }

  // ─── BodyMeasurements ───────────────────────────────────────────────────────

  Future<List<BodyMeasurement>> getAllMeasurements() async {
    final db = await database;
    final rows = await db.query('body_measurements', orderBy: 'timestamp DESC');
    return rows.map(BodyMeasurement.fromMap).toList();
  }

  Future<int> insertMeasurement(BodyMeasurement measurement) async {
    final db = await database;
    return db.insert('body_measurements', measurement.toMap());
  }

  Future<void> deleteMeasurement(int id) async {
    final db = await database;
    await db.delete('body_measurements', where: 'id = ?', whereArgs: [id]);
  }

  // ─── PersonalRecords (computed) ─────────────────────────────────────────────

  Future<List<PersonalRecord>> getPersonalRecords() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT
        exerciseId,
        exerciseName,
        MAX(weightKg) AS maxWeightKg,
        MAX(reps) AS maxReps,
        MAX(weightKg * reps) AS maxVolumeSet,
        COUNT(*) AS totalSets
      FROM workout_set_records
      GROUP BY exerciseId
      ORDER BY maxWeightKg DESC
    ''');
    return rows
        .map((r) => PersonalRecord(
              exerciseId: r['exerciseId'] as String,
              exerciseName: r['exerciseName'] as String,
              maxWeightKg: (r['maxWeightKg'] as num).toDouble(),
              maxReps: r['maxReps'] as int,
              maxVolumeSetKg: (r['maxVolumeSet'] as num).toDouble(),
              totalLoggedSets: r['totalSets'] as int,
            ))
        .toList();
  }
}
