// ─── Enums ───────────────────────────────────────────────────────────────────

enum Gender { male, female, other }

enum FitnessGoal {
  generalFitness('General Fitness'),
  muscleGain('Muscle Gain'),
  fatLoss('Fat Loss'),
  strength('Strength'),
  endurance('Endurance');

  const FitnessGoal(this.label);
  final String label;
}

enum ActivityLevel {
  sedentary('Sedentary (Little or no exercise)', 1.2),
  lightlyActive('Lightly Active (1-3 days/week)', 1.375),
  moderatelyActive('Moderately Active (3-5 days/week)', 1.55),
  veryActive('Very Active (6-7 days/week)', 1.725),
  extraActive('Extra Active (Intense daily training)', 1.9);

  const ActivityLevel(this.label, this.multiplier);
  final String label;
  final double multiplier;
}

enum UnitSystem { metric, imperial }

// ─── UserProfile ─────────────────────────────────────────────────────────────

class UserProfile {
  final int id;
  final String name;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final FitnessGoal fitnessGoal;
  final ActivityLevel activityLevel;
  final UnitSystem unitSystem;
  final int lastUpdated;

  const UserProfile({
    this.id = 1,
    this.name = 'Athlete',
    this.age = 26,
    this.gender = Gender.male,
    this.heightCm = 178.0,
    this.weightKg = 76.5,
    this.fitnessGoal = FitnessGoal.muscleGain,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.unitSystem = UnitSystem.metric,
    this.lastUpdated = 0,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    FitnessGoal? fitnessGoal,
    ActivityLevel? activityLevel,
    UnitSystem? unitSystem,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      unitSystem: unitSystem ?? this.unitSystem,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'age': age,
        'gender': gender.index,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'fitnessGoal': fitnessGoal.index,
        'activityLevel': activityLevel.index,
        'unitSystem': unitSystem.index,
        'lastUpdated': lastUpdated,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id'] as int,
        name: m['name'] as String,
        age: m['age'] as int,
        gender: Gender.values[m['gender'] as int],
        heightCm: (m['heightCm'] as num).toDouble(),
        weightKg: (m['weightKg'] as num).toDouble(),
        fitnessGoal: FitnessGoal.values[m['fitnessGoal'] as int],
        activityLevel: ActivityLevel.values[m['activityLevel'] as int],
        unitSystem: UnitSystem.values[m['unitSystem'] as int],
        lastUpdated: m['lastUpdated'] as int,
      );
}

// ─── Exercise ────────────────────────────────────────────────────────────────

class Exercise {
  final String id;
  final String name;
  final String primaryMuscle;
  final String secondaryMuscles;
  final String equipment;
  final String difficulty;
  final String exerciseType;
  final String instructions;
  final String startingPosition;
  final String executionSteps;
  final String commonMistakes;
  final String formSafetyNotes;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.exerciseType,
    required this.instructions,
    required this.startingPosition,
    required this.executionSteps,
    required this.commonMistakes,
    required this.formSafetyNotes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'primaryMuscle': primaryMuscle,
        'secondaryMuscles': secondaryMuscles,
        'equipment': equipment,
        'difficulty': difficulty,
        'exerciseType': exerciseType,
        'instructions': instructions,
        'startingPosition': startingPosition,
        'executionSteps': executionSteps,
        'commonMistakes': commonMistakes,
        'formSafetyNotes': formSafetyNotes,
      };

  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
        id: m['id'] as String,
        name: m['name'] as String,
        primaryMuscle: m['primaryMuscle'] as String,
        secondaryMuscles: m['secondaryMuscles'] as String,
        equipment: m['equipment'] as String,
        difficulty: m['difficulty'] as String,
        exerciseType: m['exerciseType'] as String,
        instructions: m['instructions'] as String,
        startingPosition: m['startingPosition'] as String,
        executionSteps: m['executionSteps'] as String,
        commonMistakes: m['commonMistakes'] as String,
        formSafetyNotes: m['formSafetyNotes'] as String,
      );
}

// ─── WorkoutTemplate ─────────────────────────────────────────────────────────

class WorkoutTemplate {
  final int id;
  final String name;
  final String targetFocus;
  final String exerciseIdsJson; // comma-separated
  final String notes;
  final int createdAt;

  const WorkoutTemplate({
    this.id = 0,
    required this.name,
    required this.targetFocus,
    required this.exerciseIdsJson,
    this.notes = '',
    this.createdAt = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'name': name,
        'targetFocus': targetFocus,
        'exerciseIdsJson': exerciseIdsJson,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory WorkoutTemplate.fromMap(Map<String, dynamic> m) => WorkoutTemplate(
        id: m['id'] as int,
        name: m['name'] as String,
        targetFocus: m['targetFocus'] as String,
        exerciseIdsJson: m['exerciseIdsJson'] as String,
        notes: m['notes'] as String,
        createdAt: m['createdAt'] as int,
      );
}

// ─── WorkoutSession ──────────────────────────────────────────────────────────

class WorkoutSession {
  final int id;
  final String templateName;
  final int startTime;
  final int endTime;
  final int durationSeconds;
  final double totalVolumeKg;
  final int totalSets;
  final int totalReps;
  final String notes;

  const WorkoutSession({
    this.id = 0,
    required this.templateName,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.totalSets,
    required this.totalReps,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'templateName': templateName,
        'startTime': startTime,
        'endTime': endTime,
        'durationSeconds': durationSeconds,
        'totalVolumeKg': totalVolumeKg,
        'totalSets': totalSets,
        'totalReps': totalReps,
        'notes': notes,
      };

  factory WorkoutSession.fromMap(Map<String, dynamic> m) => WorkoutSession(
        id: m['id'] as int,
        templateName: m['templateName'] as String,
        startTime: m['startTime'] as int,
        endTime: m['endTime'] as int,
        durationSeconds: m['durationSeconds'] as int,
        totalVolumeKg: (m['totalVolumeKg'] as num).toDouble(),
        totalSets: m['totalSets'] as int,
        totalReps: m['totalReps'] as int,
        notes: m['notes'] as String,
      );
}

// ─── WorkoutSetRecord ─────────────────────────────────────────────────────────

class WorkoutSetRecord {
  final int id;
  final int sessionId;
  final String exerciseId;
  final String exerciseName;
  final int setNumber;
  final double weightKg;
  final int reps;

  const WorkoutSetRecord({
    this.id = 0,
    required this.sessionId,
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
  });

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'sessionId': sessionId,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'setNumber': setNumber,
        'weightKg': weightKg,
        'reps': reps,
      };

  factory WorkoutSetRecord.fromMap(Map<String, dynamic> m) => WorkoutSetRecord(
        id: m['id'] as int,
        sessionId: m['sessionId'] as int,
        exerciseId: m['exerciseId'] as String,
        exerciseName: m['exerciseName'] as String,
        setNumber: m['setNumber'] as int,
        weightKg: (m['weightKg'] as num).toDouble(),
        reps: m['reps'] as int,
      );
}

// ─── BodyMeasurement ─────────────────────────────────────────────────────────

class BodyMeasurement {
  final int id;
  final int timestamp;
  final double weightKg;
  final double? chestCm;
  final double? waistCm;
  final double? armsCm;
  final double? hipsCm;
  final double? thighsCm;
  final String notes;

  const BodyMeasurement({
    this.id = 0,
    required this.timestamp,
    required this.weightKg,
    this.chestCm,
    this.waistCm,
    this.armsCm,
    this.hipsCm,
    this.thighsCm,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        if (id != 0) 'id': id,
        'timestamp': timestamp,
        'weightKg': weightKg,
        'chestCm': chestCm,
        'waistCm': waistCm,
        'armsCm': armsCm,
        'hipsCm': hipsCm,
        'thighsCm': thighsCm,
        'notes': notes,
      };

  factory BodyMeasurement.fromMap(Map<String, dynamic> m) => BodyMeasurement(
        id: m['id'] as int,
        timestamp: m['timestamp'] as int,
        weightKg: (m['weightKg'] as num).toDouble(),
        chestCm: m['chestCm'] != null ? (m['chestCm'] as num).toDouble() : null,
        waistCm: m['waistCm'] != null ? (m['waistCm'] as num).toDouble() : null,
        armsCm: m['armsCm'] != null ? (m['armsCm'] as num).toDouble() : null,
        hipsCm: m['hipsCm'] != null ? (m['hipsCm'] as num).toDouble() : null,
        thighsCm: m['thighsCm'] != null ? (m['thighsCm'] as num).toDouble() : null,
        notes: m['notes'] as String,
      );
}

// ─── UserAccount ─────────────────────────────────────────────────────────────

class UserAccount {
  final int id;
  final bool isLoggedIn;
  final String userId;
  final String email;
  final String displayName;
  final String membershipTier;
  final String authProvider;
  final int lastLoginTimestamp;
  final int accountCreatedAt;

  const UserAccount({
    this.id = 1,
    this.isLoggedIn = true,
    this.userId = 'usr_ff_73921',
    this.email = 'athlete@fitfudge.com',
    this.displayName = 'Alex Vance',
    this.membershipTier = 'FitFudge Pro Athlete',
    this.authProvider = 'Email & Password',
    this.lastLoginTimestamp = 0,
    this.accountCreatedAt = 0,
  });

  UserAccount copyWith({
    bool? isLoggedIn,
    String? email,
    String? displayName,
    int? lastLoginTimestamp,
  }) =>
      UserAccount(
        id: id,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        userId: userId,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        membershipTier: membershipTier,
        authProvider: authProvider,
        lastLoginTimestamp: lastLoginTimestamp ?? this.lastLoginTimestamp,
        accountCreatedAt: accountCreatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'isLoggedIn': isLoggedIn ? 1 : 0,
        'userId': userId,
        'email': email,
        'displayName': displayName,
        'membershipTier': membershipTier,
        'authProvider': authProvider,
        'lastLoginTimestamp': lastLoginTimestamp,
        'accountCreatedAt': accountCreatedAt,
      };

  factory UserAccount.fromMap(Map<String, dynamic> m) => UserAccount(
        id: m['id'] as int,
        isLoggedIn: (m['isLoggedIn'] as int) == 1,
        userId: m['userId'] as String,
        email: m['email'] as String,
        displayName: m['displayName'] as String,
        membershipTier: m['membershipTier'] as String,
        authProvider: m['authProvider'] as String,
        lastLoginTimestamp: m['lastLoginTimestamp'] as int,
        accountCreatedAt: m['accountCreatedAt'] as int,
      );
}

// ─── PersonalRecord ──────────────────────────────────────────────────────────

class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final double maxWeightKg;
  final int maxReps;
  final double maxVolumeSetKg;
  final int totalLoggedSets;

  const PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxWeightKg,
    required this.maxReps,
    required this.maxVolumeSetKg,
    required this.totalLoggedSets,
  });
}

// ─── DashboardStats ──────────────────────────────────────────────────────────

class DashboardStats {
  final int totalWorkouts;
  final int weeklyWorkouts;
  final int currentStreakDays;
  final double totalTrainingVolumeKg;
  final WorkoutSession? recentSession;
  final double currentWeightKg;

  const DashboardStats({
    this.totalWorkouts = 0,
    this.weeklyWorkouts = 0,
    this.currentStreakDays = 0,
    this.totalTrainingVolumeKg = 0,
    this.recentSession,
    this.currentWeightKg = 77.0,
  });
}

// ─── Active Workout ──────────────────────────────────────────────────────────

class ActiveWorkoutSet {
  final int setNumber;
  String weightInput;
  String repsInput;
  bool isCompleted;

  ActiveWorkoutSet({
    required this.setNumber,
    this.weightInput = '50.0',
    this.repsInput = '10',
    this.isCompleted = false,
  });

  ActiveWorkoutSet copyWith({
    String? weightInput,
    String? repsInput,
    bool? isCompleted,
  }) =>
      ActiveWorkoutSet(
        setNumber: setNumber,
        weightInput: weightInput ?? this.weightInput,
        repsInput: repsInput ?? this.repsInput,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

class ActiveWorkoutExercise {
  final Exercise exercise;
  final List<ActiveWorkoutSet> sets;

  ActiveWorkoutExercise({required this.exercise, required this.sets});
}
