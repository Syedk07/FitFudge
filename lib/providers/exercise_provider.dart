import 'package:flutter/foundation.dart';
import '../data/db/database_helper.dart';
import '../data/exercises/exercise_data.dart';
import '../data/model/models.dart';

class ExerciseProvider extends ChangeNotifier {
  List<Exercise> _allExercises = [];
  List<Exercise> _filtered = [];
  String _searchQuery = '';
  String _filterMuscle = '';
  String _filterDifficulty = '';
  String _filterEquipment = '';
  bool _isLoading = false;

  List<Exercise> get exercises => _filtered;
  List<Exercise> get allExercises => _allExercises;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get filterMuscle => _filterMuscle;
  String get filterDifficulty => _filterDifficulty;
  String get filterEquipment => _filterEquipment;

  List<String> get muscleGroups {
    final groups = _allExercises.map((e) => e.primaryMuscle).toSet().toList();
    groups.sort();
    return groups;
  }

  List<String> get difficulties =>
      ['Beginner', 'Intermediate', 'Advanced'];

  List<String> get equipmentTypes {
    final types = <String>{};
    for (final e in _allExercises) {
      for (final eq in e.equipment.split(',')) {
        final trimmed = eq.trim();
        if (trimmed.isNotEmpty) types.add(trimmed);
      }
    }
    final list = types.toList()..sort();
    return list;
  }

  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();

    final db = DatabaseHelper.instance;

    // Seed the database on first launch
    final seeded = await db.exercisesSeeded();
    if (!seeded) {
      await db.insertExercises(kExercises);
    }

    _allExercises = await db.getAllExercises();
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByMuscle(String muscle) {
    _filterMuscle = muscle;
    _applyFilters();
    notifyListeners();
  }

  void filterByDifficulty(String difficulty) {
    _filterDifficulty = difficulty;
    _applyFilters();
    notifyListeners();
  }

  void filterByEquipment(String equipment) {
    _filterEquipment = equipment;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterMuscle = '';
    _filterDifficulty = '';
    _filterEquipment = '';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filtered = _allExercises.where((e) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!e.name.toLowerCase().contains(q) &&
            !e.primaryMuscle.toLowerCase().contains(q) &&
            !e.equipment.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_filterMuscle.isNotEmpty && e.primaryMuscle != _filterMuscle) {
        return false;
      }
      if (_filterDifficulty.isNotEmpty && e.difficulty != _filterDifficulty) {
        return false;
      }
      if (_filterEquipment.isNotEmpty &&
          !e.equipment.toLowerCase().contains(_filterEquipment.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  Exercise? getById(String id) {
    try {
      return _allExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
