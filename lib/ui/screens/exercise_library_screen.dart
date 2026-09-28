import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exercise_provider.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'exercise_detail_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();

    return Scaffold(
      appBar: FitFudgeAppBar(
        title: 'Exercises',
        actions: [
          if (provider.filterMuscle.isNotEmpty ||
              provider.filterDifficulty.isNotEmpty ||
              provider.filterEquipment.isNotEmpty)
            TextButton(
              onPressed: () {
                provider.clearFilters();
                _searchController.clear();
              },
              child: const Text('Clear'),
            ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterSheet(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              ),
              onChanged: provider.search,
            ),
          ),

          // Active filter chips
          if (provider.filterMuscle.isNotEmpty ||
              provider.filterDifficulty.isNotEmpty ||
              provider.filterEquipment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (provider.filterMuscle.isNotEmpty)
                      _ActiveFilterChip(
                        label: provider.filterMuscle,
                        onRemove: () => provider.filterByMuscle(''),
                      ),
                    if (provider.filterDifficulty.isNotEmpty)
                      _ActiveFilterChip(
                        label: provider.filterDifficulty,
                        onRemove: () => provider.filterByDifficulty(''),
                      ),
                    if (provider.filterEquipment.isNotEmpty)
                      _ActiveFilterChip(
                        label: provider.filterEquipment,
                        onRemove: () => provider.filterByEquipment(''),
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${provider.exercises.length} exercise${provider.exercises.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Exercise list
          Expanded(
            child: provider.isLoading
                ? const LoadingOverlay()
                : provider.exercises.isEmpty
                    ? EmptyState(
                        icon: Icons.fitness_center_outlined,
                        title: 'No exercises found',
                        message:
                            'Try adjusting your search or filters.',
                        buttonLabel:
                            provider.searchQuery.isNotEmpty ||
                                    provider.filterMuscle.isNotEmpty
                                ? 'Clear Filters'
                                : null,
                        onButton: () {
                          provider.clearFilters();
                          _searchController.clear();
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: provider.exercises.length,
                        itemBuilder: (context, i) {
                          final ex = provider.exercises[i];
                          return ExerciseCard(
                            exercise: ex,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExerciseDetailScreen(exercise: ex),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ExerciseProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _FilterSheet(provider: provider),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.secondary, fontSize: 13)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                color: AppColors.secondary, size: 14),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final ExerciseProvider provider;
  const _FilterSheet({required this.provider});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _muscle;
  late String _difficulty;

  @override
  void initState() {
    super.initState();
    _muscle = widget.provider.filterMuscle;
    _difficulty = widget.provider.filterDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Filter Exercises',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),

          // Muscle Group
          Text('Muscle Group',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.provider.muscleGroups.map((m) {
              final selected = _muscle == m;
              return GestureDetector(
                onTap: () => setState(() => _muscle = selected ? '' : m),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? muscleGroupColor(m).withValues(alpha: 0.25)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? muscleGroupColor(m)
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    m,
                    style: TextStyle(
                      color: selected
                          ? muscleGroupColor(m)
                          : AppColors.textSecondary,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Difficulty
          Text('Difficulty',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: widget.provider.difficulties.map((d) {
              final selected = _difficulty == d;
              final color = difficultyColor(d);
              return GestureDetector(
                onTap: () =>
                    setState(() => _difficulty = selected ? '' : d),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.2)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: selected ? color : AppColors.border),
                  ),
                  child: Text(d,
                      style: TextStyle(
                        color: selected ? color : AppColors.textSecondary,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.normal,
                        fontSize: 13,
                      )),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.provider.filterByMuscle(_muscle);
                widget.provider.filterByDifficulty(_difficulty);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
