import 'package:flutter/foundation.dart';
import '../data/db/database_helper.dart';
import '../data/model/models.dart';

class BodyMeasurementProvider extends ChangeNotifier {
  List<BodyMeasurement> _measurements = [];
  bool _isLoading = false;

  List<BodyMeasurement> get measurements => _measurements;
  bool get isLoading => _isLoading;

  BodyMeasurement? get latest =>
      _measurements.isNotEmpty ? _measurements.first : null;

  Future<void> loadMeasurements() async {
    _isLoading = true;
    notifyListeners();

    _measurements = await DatabaseHelper.instance.getAllMeasurements();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMeasurement(BodyMeasurement measurement) async {
    final id = await DatabaseHelper.instance.insertMeasurement(measurement);
    final saved = BodyMeasurement(
      id: id,
      timestamp: measurement.timestamp,
      weightKg: measurement.weightKg,
      chestCm: measurement.chestCm,
      waistCm: measurement.waistCm,
      armsCm: measurement.armsCm,
      hipsCm: measurement.hipsCm,
      thighsCm: measurement.thighsCm,
      notes: measurement.notes,
    );
    _measurements.insert(0, saved);
    notifyListeners();
  }

  Future<void> deleteMeasurement(int id) async {
    await DatabaseHelper.instance.deleteMeasurement(id);
    _measurements.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  /// Weight history as list of [timestamp, weightKg] pairs (chronological).
  List<MapEntry<DateTime, double>> get weightHistory {
    return _measurements
        .reversed
        .map((m) => MapEntry(
              DateTime.fromMillisecondsSinceEpoch(m.timestamp),
              m.weightKg,
            ))
        .toList();
  }

  /// Returns the change in weight between the two most recent entries.
  double? get weightChange {
    if (_measurements.length < 2) return null;
    return _measurements.first.weightKg - _measurements[1].weightKg;
  }
}
