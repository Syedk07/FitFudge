import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/workout_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/body_measurement_provider.dart';
import '../../data/calculator/fitness_calculator.dart';
import '../../data/model/models.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'workout_templates_screen.dart';
import 'body_measurements_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final user = context.watch<UserProvider>();
    final body = context.watch<BodyMeasurementProvider>();
    final stats = workout.dashboardStats;
    final profile = user.profile;
    final units = profile.unitSystem;

    final macros = FitnessCalculator.calculateMacros(profile);

    return Scaffold(
      appBar: FitFudgeAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () async {
          await workout.loadAll();
          await body.loadMeasurements();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _GreetingBanner(profile: profile),
              const SizedBox(height: 20),

              // Quick Start
              if (!workout.isWorkoutActive)
                _QuickStartCard(onStart: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WorkoutTemplatesScreen()),
                  );
                }),

              // Stats Grid
              const SizedBox(height: 20),
              const SectionHeader(title: 'Your Stats'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    label: 'Total Workouts',
                    value: '${stats.totalWorkouts}',
                    icon: Icons.fitness_center,
                    color: AppColors.secondary,
                  ),
                  StatCard(
                    label: 'This Week',
                    value: '${stats.weeklyWorkouts}',
                    icon: Icons.calendar_today,
                    color: AppColors.secondary,
                  ),
                  StatCard(
                    label: 'Day Streak',
                    value: '${stats.currentStreakDays}',
                    subtitle: stats.currentStreakDays > 0 ? '🔥' : null,
                    icon: Icons.local_fire_department,
                    color: AppColors.warning,
                  ),
                  StatCard(
                    label: 'Total Volume',
                    value: units == UnitSystem.metric
                        ? '${(stats.totalTrainingVolumeKg / 1000).toStringAsFixed(1)}t'
                        : '${(stats.totalTrainingVolumeKg * 2.20462 / 1000).toStringAsFixed(1)}t',
                    icon: Icons.bar_chart,
                    color: AppColors.success,
                  ),
                ],
              ),

              // Nutrition Summary
              const SizedBox(height: 24),
              const SectionHeader(title: 'Nutrition Targets'),
              const SizedBox(height: 12),
              _NutritionCard(macros: macros, goal: profile.fitnessGoal),

              // Body Stats
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Body Stats',
                actionLabel: 'Log',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BodyMeasurementsScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _BodyStatsCard(profile: profile, latest: body.latest),

              // Recent Session
              if (stats.recentSession != null) ...[
                const SizedBox(height: 24),
                const SectionHeader(title: 'Last Workout'),
                const SizedBox(height: 12),
                _RecentSessionCard(session: stats.recentSession!),
              ],

              // Personal Records
              if (workout.personalRecords.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionHeader(title: 'Personal Records'),
                const SizedBox(height: 12),
                ...workout.personalRecords.take(5).map(
                      (pr) => _PRTile(pr: pr, units: units),
                    ),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _GreetingBanner extends StatelessWidget {
  final UserProfile profile;
  const _GreetingBanner({required this.profile});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()},',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                profile.name,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final VoidCallback onStart;
  const _QuickStartCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStart,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.secondaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'START WORKOUT',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose a template or start custom',
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: AppColors.primary, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final MacroTargets macros;
  final FitnessGoal goal;
  const _NutritionCard({required this.macros, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${macros.calories.round()} kcal / day',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goal.label,
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MacroItem(
                  label: 'Protein',
                  value: '${macros.proteinG.round()}g',
                  color: AppColors.error),
              _MacroItem(
                  label: 'Carbs',
                  value: '${macros.carbG.round()}g',
                  color: AppColors.secondary),
              _MacroItem(
                  label: 'Fat',
                  value: '${macros.fatG.round()}g',
                  color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _BodyStatsCard extends StatelessWidget {
  final UserProfile profile;
  final BodyMeasurement? latest;
  const _BodyStatsCard({required this.profile, this.latest});

  @override
  Widget build(BuildContext context) {
    final bmi = FitnessCalculator.calculateBMI(
        latest?.weightKg ?? profile.weightKg, profile.heightCm);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _BodyStatItem(
            label: 'Weight',
            value: profile.unitSystem == UnitSystem.metric
                ? '${(latest?.weightKg ?? profile.weightKg).toStringAsFixed(1)} kg'
                : '${FitnessCalculator.kgToLbs(latest?.weightKg ?? profile.weightKg).toStringAsFixed(1)} lbs',
            icon: Icons.monitor_weight_outlined,
          ),
          const _VerticalDivider(),
          _BodyStatItem(
            label: 'Height',
            value: profile.unitSystem == UnitSystem.metric
                ? '${profile.heightCm.toStringAsFixed(0)} cm'
                : FitnessCalculator.cmToFeetInches(profile.heightCm),
            icon: Icons.height,
          ),
          const _VerticalDivider(),
          _BodyStatItem(
            label: 'BMI',
            value: bmi.toStringAsFixed(1),
            subtitle: FitnessCalculator.bmiCategory(bmi),
            icon: Icons.analytics_outlined,
          ),
        ],
      ),
    );
  }
}

class _BodyStatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  const _BodyStatItem(
      {required this.label,
      required this.value,
      this.subtitle,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.textMuted)),
          if (subtitle != null)
            Text(subtitle!,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.divider,
    );
  }
}

class _RecentSessionCard extends StatelessWidget {
  final WorkoutSession session;
  const _RecentSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final date =
        DateFormat('EEE, MMM d').format(
            DateTime.fromMillisecondsSinceEpoch(session.startTime));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(session.templateName,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis),
              ),
              Text(date,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SessionStat(
                  icon: Icons.timer_outlined,
                  value: formatDuration(session.durationSeconds)),
              _SessionStat(
                  icon: Icons.fitness_center,
                  value: '${session.totalSets} sets'),
              _SessionStat(
                  icon: Icons.repeat,
                  value: '${session.totalReps} reps'),
              _SessionStat(
                  icon: Icons.bar_chart,
                  value: '${session.totalVolumeKg.round()} kg'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _SessionStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PRTile extends StatelessWidget {
  final PersonalRecord pr;
  final UnitSystem units;
  const _PRTile({required this.pr, required this.units});

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(pr.exerciseName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                overflow: TextOverflow.ellipsis),
          ),
          Text(
            formatWeight(pr.maxWeightKg, units),
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text('× ${pr.maxReps}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
