import 'package:flutter/material.dart';
import '../../data/model/models.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero app bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      muscleGroupColor(exercise.primaryMuscle).withValues(alpha: 0.3),
                      AppColors.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: muscleGroupColor(exercise.primaryMuscle)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: muscleGroupColor(exercise.primaryMuscle),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + badges
                  Text(exercise.name,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MuscleChip(label: exercise.primaryMuscle),
                      DifficultyBadge(difficulty: exercise.difficulty),
                      _TypeBadge(type: exercise.exerciseType),
                    ],
                  ),

                  // Overview
                  const SizedBox(height: 24),
                  _InfoCard(
                    title: 'Overview',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.instructions,
                            style: Theme.of(context).textTheme.bodyMedium),
                        if (exercise.secondaryMuscles.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          InfoRow(
                              label: 'Secondary',
                              value: exercise.secondaryMuscles),
                        ],
                        const SizedBox(height: 4),
                        InfoRow(label: 'Equipment', value: exercise.equipment),
                      ],
                    ),
                  ),

                  // Starting Position
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Starting Position',
                    icon: Icons.start,
                    child: Text(exercise.startingPosition,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),

                  // Execution Steps
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'How to Perform',
                    icon: Icons.format_list_numbered,
                    child: Text(exercise.executionSteps,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),

                  // Common Mistakes
                  if (exercise.commonMistakes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Common Mistakes',
                      icon: Icons.warning_amber_outlined,
                      iconColor: AppColors.warning,
                      child: Text(exercise.commonMistakes,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                    ),
                  ],

                  // Safety Notes
                  if (exercise.formSafetyNotes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Form & Safety',
                      icon: Icons.shield_outlined,
                      iconColor: AppColors.success,
                      child: Text(exercise.formSafetyNotes,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget child;

  const _InfoCard({
    required this.title,
    this.icon,
    this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                      )),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
