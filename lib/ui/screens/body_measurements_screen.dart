import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/body_measurement_provider.dart';
import '../../providers/user_provider.dart';
import '../../data/model/models.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class BodyMeasurementsScreen extends StatelessWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BodyMeasurementProvider>();
    final units = context.watch<UserProvider>().profile.unitSystem;

    return Scaffold(
      appBar: FitFudgeAppBar(
        title: 'Body Measurements',
        showBack: true,
      ),
      body: provider.isLoading
          ? const LoadingOverlay()
          : provider.measurements.isEmpty
              ? EmptyState(
                  icon: Icons.monitor_weight_outlined,
                  title: 'No Measurements',
                  message:
                      'Start logging your body measurements to track progress.',
                  buttonLabel: 'Log Measurement',
                  onButton: () => _showLogSheet(context),
                )
              : Column(
                  children: [
                    // Latest summary card
                    if (provider.latest != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _LatestCard(
                            measurement: provider.latest!, units: units),
                      ),

                    const SizedBox(height: 8),

                    // History list
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: provider.measurements.length,
                        itemBuilder: (context, i) => _MeasurementTile(
                          measurement: provider.measurements[i],
                          units: units,
                          onDelete: () => _confirmDelete(
                              context,
                              provider,
                              provider.measurements[i]),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _LogMeasurementSheet(),
    );
  }

  void _confirmDelete(BuildContext context, BodyMeasurementProvider provider,
      BodyMeasurement m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Entry'),
        content: const Text('Delete this measurement? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteMeasurement(m.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Latest Card ──────────────────────────────────────────────────────────────

class _LatestCard extends StatelessWidget {
  final BodyMeasurement measurement;
  final UnitSystem units;

  const _LatestCard({required this.measurement, required this.units});

  @override
  Widget build(BuildContext context) {
    final weight = units == UnitSystem.metric
        ? '${measurement.weightKg.toStringAsFixed(1)} kg'
        : '${(measurement.weightKg * 2.20462).toStringAsFixed(1)} lbs';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Weight',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(weight,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (measurement.chestCm != null ||
              measurement.waistCm != null ||
              measurement.armsCm != null)
            Wrap(
              spacing: 16,
              children: [
                if (measurement.chestCm != null)
                  _MiniStat(
                      label: 'Chest',
                      value: '${measurement.chestCm!.toStringAsFixed(1)} cm'),
                if (measurement.waistCm != null)
                  _MiniStat(
                      label: 'Waist',
                      value: '${measurement.waistCm!.toStringAsFixed(1)} cm'),
                if (measurement.armsCm != null)
                  _MiniStat(
                      label: 'Arms',
                      value: '${measurement.armsCm!.toStringAsFixed(1)} cm'),
                if (measurement.hipsCm != null)
                  _MiniStat(
                      label: 'Hips',
                      value: '${measurement.hipsCm!.toStringAsFixed(1)} cm'),
                if (measurement.thighsCm != null)
                  _MiniStat(
                      label: 'Thighs',
                      value: '${measurement.thighsCm!.toStringAsFixed(1)} cm'),
              ],
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

// ─── Measurement Tile ─────────────────────────────────────────────────────────

class _MeasurementTile extends StatelessWidget {
  final BodyMeasurement measurement;
  final UnitSystem units;
  final VoidCallback onDelete;

  const _MeasurementTile({
    required this.measurement,
    required this.units,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE, MMM d, y').format(
        DateTime.fromMillisecondsSinceEpoch(measurement.timestamp));

    final weight = units == UnitSystem.metric
        ? '${measurement.weightKg.toStringAsFixed(1)} kg'
        : '${(measurement.weightKg * 2.20462).toStringAsFixed(1)} lbs';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(weight,
                    style: Theme.of(context).textTheme.titleLarge),
                if (measurement.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(measurement.notes,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline,
                color: AppColors.textMuted, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── Log Measurement Sheet ────────────────────────────────────────────────────

class _LogMeasurementSheet extends StatefulWidget {
  const _LogMeasurementSheet();

  @override
  State<_LogMeasurementSheet> createState() => _LogMeasurementSheetState();
}

class _LogMeasurementSheetState extends State<_LogMeasurementSheet> {
  final _weightCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _armsCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _thighsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _chestCtrl.dispose();
    _waistCtrl.dispose();
    _armsCtrl.dispose();
    _hipsCtrl.dispose();
    _thighsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Log Measurement',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            _field('Weight (kg) *', _weightCtrl),
            _field('Chest (cm)', _chestCtrl),
            _field('Waist (cm)', _waistCtrl),
            _field('Arms (cm)', _armsCtrl),
            _field('Hips (cm)', _hipsCtrl),
            _field('Thighs (cm)', _thighsCtrl),

            const SizedBox(height: 4),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final w = double.tryParse(_weightCtrl.text);
                  if (w == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a valid weight.'),
                          backgroundColor: AppColors.error),
                    );
                    return;
                  }

                  final m = BodyMeasurement(
                    timestamp: DateTime.now().millisecondsSinceEpoch,
                    weightKg: w,
                    chestCm: double.tryParse(_chestCtrl.text),
                    waistCm: double.tryParse(_waistCtrl.text),
                    armsCm: double.tryParse(_armsCtrl.text),
                    hipsCm: double.tryParse(_hipsCtrl.text),
                    thighsCm: double.tryParse(_thighsCtrl.text),
                    notes: _notesCtrl.text.trim(),
                  );

                  context.read<BodyMeasurementProvider>().addMeasurement(m);
                  Navigator.pop(context);
                },
                child: const Text('Save Measurement'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
