import '../model/models.dart';

/// All fitness calculation logic: BMR, TDEE, macros, body composition.
class FitnessCalculator {
  /// Mifflin-St Jeor BMR equation (most accurate general formula).
  static double calculateBMR(UserProfile profile) {
    final w = profile.weightKg;
    final h = profile.heightCm;
    final a = profile.age;

    switch (profile.gender) {
      case Gender.male:
        return (10 * w) + (6.25 * h) - (5 * a) + 5;
      case Gender.female:
        return (10 * w) + (6.25 * h) - (5 * a) - 161;
      case Gender.other:
        // Average of male and female formulas
        final male = (10 * w) + (6.25 * h) - (5 * a) + 5;
        final female = (10 * w) + (6.25 * h) - (5 * a) - 161;
        return (male + female) / 2;
    }
  }

  /// TDEE = BMR × activity multiplier.
  static double calculateTDEE(UserProfile profile) {
    return calculateBMR(profile) * profile.activityLevel.multiplier;
  }

  /// Daily calorie target adjusted for fitness goal.
  static double calculateTargetCalories(UserProfile profile) {
    final tdee = calculateTDEE(profile);
    switch (profile.fitnessGoal) {
      case FitnessGoal.muscleGain:
        return tdee + 300; // Lean bulk surplus
      case FitnessGoal.fatLoss:
        return tdee - 500; // Moderate deficit
      case FitnessGoal.strength:
        return tdee + 200; // Small surplus
      case FitnessGoal.endurance:
        return tdee + 100; // Slight surplus for recovery
      case FitnessGoal.generalFitness:
        return tdee; // Maintenance
    }
  }

  /// Macro split in grams based on goal.
  static MacroTargets calculateMacros(UserProfile profile) {
    final calories = calculateTargetCalories(profile);
    final weight = profile.weightKg;

    double proteinG, fatG, carbG;

    switch (profile.fitnessGoal) {
      case FitnessGoal.muscleGain:
        proteinG = weight * 2.2; // ~1g per lb
        fatG = (calories * 0.25) / 9;
        carbG = (calories - (proteinG * 4) - (fatG * 9)) / 4;
        break;
      case FitnessGoal.fatLoss:
        proteinG = weight * 2.4; // Higher protein on deficit
        fatG = (calories * 0.30) / 9;
        carbG = (calories - (proteinG * 4) - (fatG * 9)) / 4;
        break;
      case FitnessGoal.strength:
        proteinG = weight * 2.0;
        fatG = (calories * 0.30) / 9;
        carbG = (calories - (proteinG * 4) - (fatG * 9)) / 4;
        break;
      case FitnessGoal.endurance:
        proteinG = weight * 1.6;
        fatG = (calories * 0.25) / 9;
        carbG = (calories - (proteinG * 4) - (fatG * 9)) / 4;
        break;
      case FitnessGoal.generalFitness:
        proteinG = weight * 1.8;
        fatG = (calories * 0.28) / 9;
        carbG = (calories - (proteinG * 4) - (fatG * 9)) / 4;
    }

    return MacroTargets(
      calories: calories,
      proteinG: proteinG.clamp(0, double.infinity),
      carbG: carbG.clamp(0, double.infinity),
      fatG: fatG.clamp(0, double.infinity),
    );
  }

  /// BMI calculation.
  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// BMI category label.
  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Ideal body weight using Devine formula.
  static double idealBodyWeight(double heightCm, Gender gender) {
    final inchesOver5Ft = ((heightCm / 2.54) - 60).clamp(0, double.infinity);
    if (gender == Gender.male) {
      return 50.0 + (2.3 * inchesOver5Ft);
    } else {
      return 45.5 + (2.3 * inchesOver5Ft);
    }
  }

  /// Estimated 1-rep max using Epley formula: w × (1 + r/30).
  static double oneRepMax(double weightKg, int reps) {
    if (reps == 1) return weightKg;
    return weightKg * (1 + reps / 30.0);
  }

  /// Convert kg → lbs.
  static double kgToLbs(double kg) => kg * 2.20462;

  /// Convert lbs → kg.
  static double lbsToKg(double lbs) => lbs / 2.20462;

  /// Convert cm → ft+in string.
  static String cmToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return '$feet\'$inches"';
  }

  /// Estimated body fat % via US Navy method (requires waist & neck measurements in cm).
  static double? estimateBodyFat({
    required Gender gender,
    required double heightCm,
    required double waistCm,
    double? neckCm,
    double? hipsCm,
  }) {
    if (neckCm == null) return null;
    if (gender == Gender.male) {
      // Men: 495 / (1.0324 - 0.19077 × log10(waist−neck) + 0.15456 × log10(height)) − 450
      final logWN = _log10(waistCm - neckCm);
      final logH = _log10(heightCm);
      return 495 / (1.0324 - 0.19077 * logWN + 0.15456 * logH) - 450;
    } else {
      if (hipsCm == null) return null;
      // Women: 495 / (1.29579 - 0.35004 × log10(waist+hips−neck) + 0.22100 × log10(height)) − 450
      final logWHN = _log10(waistCm + hipsCm - neckCm);
      final logH = _log10(heightCm);
      return 495 / (1.29579 - 0.35004 * logWHN + 0.22100 * logH) - 450;
    }
  }

  static double _log10(double x) => x <= 0 ? 0 : (x == 1 ? 0 : (x / 2.302585092994046));
}

/// Macro nutrient targets result.
class MacroTargets {
  final double calories;
  final double proteinG;
  final double carbG;
  final double fatG;

  const MacroTargets({
    required this.calories,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
  });

  double get proteinCalories => proteinG * 4;
  double get carbCalories => carbG * 4;
  double get fatCalories => fatG * 9;
}
