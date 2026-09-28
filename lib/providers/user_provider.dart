import 'package:flutter/foundation.dart';
import '../data/db/database_helper.dart';
import '../data/model/models.dart';

class UserProvider extends ChangeNotifier {
  UserProfile _profile = const UserProfile();
  UserAccount _account = const UserAccount(
    lastLoginTimestamp: 0,
    accountCreatedAt: 0,
  );
  bool _isLoading = false;

  UserProfile get profile => _profile;
  UserAccount get account => _account;
  bool get isLoading => _isLoading;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    final db = DatabaseHelper.instance;
    final profile = await db.getUserProfile();
    final account = await db.getUserAccount();

    if (profile != null) _profile = profile;
    if (account != null) _account = account;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile updated) async {
    await DatabaseHelper.instance.saveUserProfile(updated);
    _profile = updated;
    notifyListeners();
  }

  Future<void> saveAccount(UserAccount updated) async {
    await DatabaseHelper.instance.saveUserAccount(updated);
    _account = updated;
    notifyListeners();
  }

  Future<void> updateProfileField({
    String? name,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    FitnessGoal? fitnessGoal,
    ActivityLevel? activityLevel,
    UnitSystem? unitSystem,
  }) async {
    final updated = _profile.copyWith(
      name: name,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      fitnessGoal: fitnessGoal,
      activityLevel: activityLevel,
      unitSystem: unitSystem,
    );
    await saveProfile(updated);
  }
}
