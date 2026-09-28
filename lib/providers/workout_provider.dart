import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/db/database_helper.dart';
import '../data/model/models.dart';

class WorkoutProvider extends ChangeNotifier {
  // ─── Templates ──────────────────────────────────────────────────────────────
  List<WorkoutTemplate> _templates = [];
  List<WorkoutTemplate> get templates => _templates;

  // ─── History ────────────────────────────────────────────────────────────────
  List<WorkoutSession> _sessions = [];
  List<WorkoutSession> get sessions => _sessions;

  // ─── Personal Records ───────────────────────────────────────────────────────
  List<PersonalRecord> _prs = [];
  List<PersonalRecord> get personalRecords => _prs;

  // ─── Active Workout ─────────────────────────────────────────────────────────
  bool _isWorkoutActive = false;
  WorkoutTemplate? _activeTemplate;
  List<ActiveWorkoutExercise> _activeExercises = [];
  DateTime? _workoutStartTime;
  Timer? _timer;
  int _elapsedSeconds = 0;

  bool get isWorkoutActive => _isWorkoutActive;
  WorkoutTemplate? get activeTemplate => _activeTemplate;
  List<ActiveWorkoutExercise> get activeExercises => _activeExercises;
  int get elapsedSeconds => _elapsedSeconds;
  DateTime? get workoutStartTime => _workoutStartTime;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ─── Load ────────────────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    final db = DatabaseHelper.instance;
    _templates = await db.getAllTemplates();
    _sessions = await db.getAllSessions();
    _prs = await db.getPersonalRecords();

    _isLoading = false;
    notifyListeners();
  }

  // ─── Templates CRUD ─────────────────────────────────────────────────────────

  Future<void> addTemplate(WorkoutTemplate template) async {
    final newTemplate = WorkoutTemplate(
      name: template.name,
      targetFocus: template.targetFocus,
      exerciseIdsJson: template.exerciseIdsJson,
      notes: template.notes,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    final id = await DatabaseHelper.instance.insertTemplate(newTemplate);
    _templates.insert(
      0,
      WorkoutTemplate(
        id: id,
        name: newTemplate.name,
        targetFocus: newTemplate.targetFocus,
        exerciseIdsJson: newTemplate.exerciseIdsJson,
        notes: newTemplate.notes,
        createdAt: newTemplate.createdAt,
      ),
    );
    notifyListeners();
  }

  Future<void> updateTemplate(WorkoutTemplate template) async {
    await DatabaseHelper.instance.updateTemplate(template);
    final idx = _templates.indexWhere((t) => t.id == template.id);
    if (idx != -1) _templates[idx] = template;
    notifyListeners();
  }

  Future<void> deleteTemplate(int id) async {
    await DatabaseHelper.instance.deleteTemplate(id);
    _templates.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ─── Active Workout ─────────────────────────────────────────────────────────

  void startWorkout(WorkoutTemplate template, List<Exercise> exercises) {
    _activeTemplate = template;
    _workoutStartTime = DateTime.now();
    _elapsedSeconds = 0;
    _activeExercises = exercises.asMap().entries.map((entry) {
      return ActiveWorkoutExercise(
        exercise: entry.value,
        sets: [ActiveWorkoutSet(setNumber: 1)],
      );
    }).toList();
    _isWorkoutActive = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });

    notifyListeners();
  }

  void addSetToExercise(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _activeExercises.length) return;
    final sets = _activeExercises[exerciseIndex].sets;
    sets.add(ActiveWorkoutSet(setNumber: sets.length + 1));
    notifyListeners();
  }

  void removeSetFromExercise(int exerciseIndex, int setIndex) {
    final sets = _activeExercises[exerciseIndex].sets;
    if (sets.length > 1) {
      sets.removeAt(setIndex);
      // Re-number sets
      for (int i = 0; i < sets.length; i++) {
        sets[i] = sets[i].copyWith();
      }
      notifyListeners();
    }
  }

  void updateSetWeight(int exerciseIndex, int setIndex, String weight) {
    final sets = _activeExercises[exerciseIndex].sets;
    sets[setIndex] = sets[setIndex].copyWith(weightInput: weight);
    // Don't notify — text field manages its own state
  }

  void updateSetReps(int exerciseIndex, int setIndex, String reps) {
    final sets = _activeExercises[exerciseIndex].sets;
    sets[setIndex] = sets[setIndex].copyWith(repsInput: reps);
    // Don't notify — text field manages its own state
  }

  void toggleSetCompletion(int exerciseIndex, int setIndex) {
    final sets = _activeExercises[exerciseIndex].sets;
    sets[setIndex] =
        sets[setIndex].copyWith(isCompleted: !sets[setIndex].isCompleted);
    notifyListeners();
  }

  Future<void> finishWorkout({String notes = ''}) async {
    if (!_isWorkoutActive || _workoutStartTime == null) return;

    _timer?.cancel();
    final endTime = DateTime.now();
    final startMs = _workoutStartTime!.millisecondsSinceEpoch;
    final endMs = endTime.millisecondsSinceEpoch;

    // Aggregate stats
    double totalVolume = 0;
    int totalSets = 0;
    int totalReps = 0;
    final setRecords = <WorkoutSetRecord>[];

    for (final ex in _activeExercises) {
      int setNum = 1;
      for (final s in ex.sets) {
        if (!s.isCompleted) continue;
        final w = double.tryParse(s.weightInput) ?? 0;
        final r = int.tryParse(s.repsInput) ?? 0;
        if (r > 0) {
          totalVolume += w * r;
          totalSets++;
          totalReps += r;
          setRecords.add(WorkoutSetRecord(
            sessionId: 0, // set after session insert
            exerciseId: ex.exercise.id,
            exerciseName: ex.exercise.name,
            setNumber: setNum++,
            weightKg: w,
            reps: r,
          ));
        }
      }
    }

    final session = WorkoutSession(
      templateName: _activeTemplate?.name ?? 'Custom Workout',
      startTime: startMs,
      endTime: endMs,
      durationSeconds: _elapsedSeconds,
      totalVolumeKg: totalVolume,
      totalSets: totalSets,
      totalReps: totalReps,
      notes: notes,
    );

    final db = DatabaseHelper.instance;
    final sessionId = await db.insertSession(session);

    final recordsWithId = setRecords
        .map((r) => WorkoutSetRecord(
              sessionId: sessionId,
              exerciseId: r.exerciseId,
              exerciseName: r.exerciseName,
              setNumber: r.setNumber,
              weightKg: r.weightKg,
              reps: r.reps,
            ))
        .toList();

    await db.insertSetRecords(recordsWithId);

    // Reload persisted data
    _sessions = await db.getAllSessions();
    _prs = await db.getPersonalRecords();

    // Reset active workout state
    _isWorkoutActive = false;
    _activeTemplate = null;
    _activeExercises = [];
    _workoutStartTime = null;
    _elapsedSeconds = 0;

    notifyListeners();
  }

  void cancelWorkout() {
    _timer?.cancel();
    _isWorkoutActive = false;
    _activeTemplate = null;
    _activeExercises = [];
    _workoutStartTime = null;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  Future<void> deleteSession(int id) async {
    await DatabaseHelper.instance.deleteSession(id);
    _sessions.removeWhere((s) => s.id == id);
    _prs = await DatabaseHelper.instance.getPersonalRecords();
    notifyListeners();
  }

  // ─── Dashboard Stats (computed) ─────────────────────────────────────────────

  DashboardStats get dashboardStats {
    final now = DateTime.now();
    final weekStart =
        DateTime(now.year, now.month, now.day - now.weekday + 1);

    final weeklyCount = _sessions
        .where((s) =>
            DateTime.fromMillisecondsSinceEpoch(s.startTime)
                .isAfter(weekStart))
        .length;

    // Streak — consecutive days with a session
    int streak = 0;
    if (_sessions.isNotEmpty) {
      DateTime checkDay = DateTime(now.year, now.month, now.day);
      for (int i = 0; i < 365; i++) {
        final hasSession = _sessions.any((s) {
          final d = DateTime.fromMillisecondsSinceEpoch(s.startTime);
          return d.year == checkDay.year &&
              d.month == checkDay.month &&
              d.day == checkDay.day;
        });
        if (hasSession) {
          streak++;
          checkDay = checkDay.subtract(const Duration(days: 1));
        } else if (i == 0) {
          checkDay = checkDay.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    final totalVolume =
        _sessions.fold<double>(0.0, (sum, s) => sum + s.totalVolumeKg);

    return DashboardStats(
      totalWorkouts: _sessions.length,
      weeklyWorkouts: weeklyCount,
      currentStreakDays: streak,
      totalTrainingVolumeKg: totalVolume,
      recentSession: _sessions.isNotEmpty ? _sessions.first : null,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
