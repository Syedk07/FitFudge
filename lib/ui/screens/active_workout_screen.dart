import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../data/model/models.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    if (!provider.isWorkoutActive) {
      return const Scaffold(
        body: Center(child: Text('No active workout.')),
      );
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.activeTemplate?.name ?? 'Custom Workout',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
              Text(
                formatDuration(provider.elapsedSeconds),
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _finishWorkout(context, provider),
              child: const Text('Finish',
                  style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            _ProgressBar(exercises: provider.activeExercises),
            Expanded(
              child: ListView.builder(
                // AlwaysScrollableScrollPhysics wraps platform default
                // (BouncingScrollPhysics on iOS, ClampingScrollPhysics on
                // Android) so pull-to-bounce feels native on both.
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: provider.activeExercises.length,
                itemBuilder: (context, i) => _ExerciseWorkoutCard(
                  exerciseIndex: i,
                  activeExercise: provider.activeExercises[i],
                  isExpanded: _expandedIndex == i,
                  onExpand: () => setState(
                      () => _expandedIndex = _expandedIndex == i ? -1 : i),
                  provider: provider,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _finishWorkout(context, provider),
          backgroundColor: AppColors.success,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Finish Workout',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  void _finishWorkout(BuildContext context, WorkoutProvider provider) {
    final completedSets = provider.activeExercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Finish Workout?'),
        content: Text(
          completedSets > 0
              ? 'You\'ve completed $completedSets set${completedSets == 1 ? '' : 's'}. Save this session?'
              : 'No sets have been completed yet. Are you sure you want to finish?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.finishWorkout();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Finish & Save',
                style: TextStyle(color: AppColors.success)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.cancelWorkout();
              Navigator.pop(context);
            },
            child: const Text('Discard',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final List<ActiveWorkoutExercise> exercises;
  const _ProgressBar({required this.exercises});

  @override
  Widget build(BuildContext context) {
    final total = exercises.fold<int>(0, (sum, e) => sum + e.sets.length);
    final done = exercises.fold<int>(
        0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length);
    final pct = total > 0 ? done / total : 0.0;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$done / $total sets completed',
                  style: Theme.of(context).textTheme.bodySmall),
              Text('${(pct * 100).round()}%',
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Exercise Workout Card ────────────────────────────────────────────────────

class _ExerciseWorkoutCard extends StatelessWidget {
  final int exerciseIndex;
  final ActiveWorkoutExercise activeExercise;
  final bool isExpanded;
  final VoidCallback onExpand;
  final WorkoutProvider provider;

  const _ExerciseWorkoutCard({
    required this.exerciseIndex,
    required this.activeExercise,
    required this.isExpanded,
    required this.onExpand,
    required this.provider,
  });

  int get _completedSets =>
      activeExercise.sets.where((s) => s.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    final ex = activeExercise.exercise;
    final allDone =
        activeExercise.sets.isNotEmpty &&
        _completedSets == activeExercise.sets.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: allDone
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onExpand,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: allDone
                          ? AppColors.success.withValues(alpha: 0.2)
                          : muscleGroupColor(ex.primaryMuscle)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      allDone
                          ? Icons.check_circle_outline
                          : Icons.fitness_center,
                      color: allDone
                          ? AppColors.success
                          : muscleGroupColor(ex.primaryMuscle),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis),
                        Text(
                          '$_completedSets / ${activeExercise.sets.length} sets',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Sets table
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      SizedBox(
                          width: 40,
                          child: Text('SET',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1))),
                      SizedBox(width: 12),
                      Expanded(
                          child: Text('WEIGHT (kg)',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1))),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text('REPS',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1))),
                      SizedBox(width: 8),
                      SizedBox(width: 44),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...activeExercise.sets.asMap().entries.map((entry) {
                    final setIndex = entry.key;
                    final set = entry.value;
                    return _SetRow(
                      setNumber: setIndex + 1,
                      set: set,
                      onWeightChanged: (v) => provider.updateSetWeight(
                          exerciseIndex, setIndex, v),
                      onRepsChanged: (v) =>
                          provider.updateSetReps(exerciseIndex, setIndex, v),
                      onToggle: () => provider.toggleSetCompletion(
                          exerciseIndex, setIndex),
                      onRemove: activeExercise.sets.length > 1
                          ? () => provider.removeSetFromExercise(
                              exerciseIndex, setIndex)
                          : null,
                    );
                  }),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          provider.addSetToExercise(exerciseIndex),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Set'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Set Row ──────────────────────────────────────────────────────────────────

class _SetRow extends StatefulWidget {
  final int setNumber;
  final ActiveWorkoutSet set;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepsChanged;
  final VoidCallback onToggle;
  final VoidCallback? onRemove;

  const _SetRow({
    required this.setNumber,
    required this.set,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onToggle,
    this.onRemove,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(text: widget.set.weightInput);
    _repsCtrl = TextEditingController(text: widget.set.repsInput);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.set.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${widget.setNumber}',
              style: TextStyle(
                color: done ? AppColors.success : AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: widget.onWeightChanged,
              style: TextStyle(
                color: done ? AppColors.success : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '0',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                fillColor: done
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.surfaceElevated,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _repsCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: widget.onRepsChanged,
              style: TextStyle(
                color: done ? AppColors.success : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '0',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                fillColor: done
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.surfaceElevated,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Platform-adaptive haptic: light impact on iOS,
                    // vibrate click on Android.
                    HapticFeedback.lightImpact();
                    widget.onToggle();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          done ? AppColors.success : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: done ? AppColors.success : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: done ? Colors.white : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ),
                if (widget.onRemove != null)
                  GestureDetector(
                    onTap: widget.onRemove,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.remove_circle_outline,
                          color: AppColors.textMuted, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
