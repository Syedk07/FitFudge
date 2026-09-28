import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../data/calculator/fitness_calculator.dart';
import '../../data/model/models.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    return Scaffold(
      appBar: FitFudgeAppBar(
        title: 'Calculator',
        showBack: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'TDEE'),
            Tab(text: 'Macros'),
            Tab(text: '1RM'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TDEETab(profile: profile),
          _MacrosTab(profile: profile),
          const _OneRMTab(),
        ],
      ),
    );
  }
}

// ─── TDEE Tab ─────────────────────────────────────────────────────────────────

class _TDEETab extends StatelessWidget {
  final UserProfile profile;
  const _TDEETab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final bmr = FitnessCalculator.calculateBMR(profile);
    final tdee = FitnessCalculator.calculateTDEE(profile);
    final target = FitnessCalculator.calculateTargetCalories(profile);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultCard(
            label: 'BMR (Basal Metabolic Rate)',
            value: '${bmr.round()} kcal',
            subtitle: 'Calories burned at complete rest',
            color: AppColors.info,
          ),
          const SizedBox(height: 12),
          _ResultCard(
            label: 'TDEE (Total Daily Energy Expenditure)',
            value: '${tdee.round()} kcal',
            subtitle: 'Maintenance calories for your activity level',
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _ResultCard(
            label: 'Daily Target (${profile.fitnessGoal.label})',
            value: '${target.round()} kcal',
            subtitle: _goalDescription(profile.fitnessGoal, tdee, target),
            color: AppColors.primary,
            isHighlighted: true,
          ),
          const SizedBox(height: 24),
          _InfoBlock(
            title: 'How is TDEE calculated?',
            content:
                'Your BMR is calculated using the Mifflin-St Jeor equation, '
                'widely considered the most accurate formula. TDEE = BMR × your activity '
                'multiplier (${profile.activityLevel.multiplier}).\n\n'
                'Your calorie target is then adjusted based on your goal: '
                '${_goalDescription(profile.fitnessGoal, tdee, target)}.',
          ),
          const SizedBox(height: 16),
          _InfoBlock(
            title: 'Your Activity Level',
            content: profile.activityLevel.label,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _goalDescription(
      FitnessGoal goal, double tdee, double target) {
    final diff = (target - tdee).round();
    switch (goal) {
      case FitnessGoal.muscleGain:
        return '+$diff kcal lean bulk surplus above maintenance';
      case FitnessGoal.fatLoss:
        return '$diff kcal deficit below maintenance';
      case FitnessGoal.strength:
        return '+$diff kcal small surplus for strength gains';
      case FitnessGoal.endurance:
        return '+$diff kcal slight surplus for endurance recovery';
      case FitnessGoal.generalFitness:
        return 'Maintenance calories';
    }
  }
}

// ─── Macros Tab ───────────────────────────────────────────────────────────────

class _MacrosTab extends StatelessWidget {
  final UserProfile profile;
  const _MacrosTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final macros = FitnessCalculator.calculateMacros(profile);
    final total = macros.proteinCalories + macros.carbCalories + macros.fatCalories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big calorie number
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Daily Calories',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${macros.calories.round()} kcal',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900)),
                Text('Goal: ${profile.fitnessGoal.label}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Macro breakdown
          _MacroBar(
            label: 'Protein',
            grams: macros.proteinG,
            calories: macros.proteinCalories,
            totalCalories: total,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          _MacroBar(
            label: 'Carbohydrates',
            grams: macros.carbG,
            calories: macros.carbCalories,
            totalCalories: total,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _MacroBar(
            label: 'Fat',
            grams: macros.fatG,
            calories: macros.fatCalories,
            totalCalories: total,
            color: AppColors.warning,
          ),

          const SizedBox(height: 24),
          _InfoBlock(
            title: 'Macro Ratios',
            content: 'Protein: ${(macros.proteinCalories / total * 100).round()}%  •  '
                'Carbs: ${(macros.carbCalories / total * 100).round()}%  •  '
                'Fat: ${(macros.fatCalories / total * 100).round()}%\n\n'
                'These are calculated based on your body weight (${profile.weightKg} kg) '
                'and your ${profile.fitnessGoal.label} goal.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double grams;
  final double calories;
  final double totalCalories;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.grams,
    required this.calories,
    required this.totalCalories,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalCalories > 0 ? calories / totalCalories : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Text('${grams.round()}g',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('${calories.round()} kcal',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 1RM Tab ──────────────────────────────────────────────────────────────────

class _OneRMTab extends StatefulWidget {
  const _OneRMTab();

  @override
  State<_OneRMTab> createState() => _OneRMTabState();
}

class _OneRMTabState extends State<_OneRMTab> {
  final _weightCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  double? _result;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final w = double.tryParse(_weightCtrl.text);
    final r = int.tryParse(_repsCtrl.text);
    if (w == null || r == null || r < 1) return;
    setState(() {
      _result = FitnessCalculator.oneRepMax(w, r);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estimate Your 1-Rep Max',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Enter the weight you lifted and the number of reps to estimate your 1RM using the Epley formula.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _weightCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Weight Lifted (kg)',
              hintText: 'e.g. 80',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _repsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Reps Performed',
              hintText: 'e.g. 6',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate 1RM'),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _ResultCard(
              label: 'Estimated 1-Rep Max',
              value: '${_result!.toStringAsFixed(1)} kg',
              subtitle:
                  '≈ ${FitnessCalculator.kgToLbs(_result!).toStringAsFixed(1)} lbs',
              color: AppColors.primary,
              isHighlighted: true,
            ),
            const SizedBox(height: 16),
            _PercentageTable(oneRM: _result!),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PercentageTable extends StatelessWidget {
  final double oneRM;
  const _PercentageTable({required this.oneRM});

  @override
  Widget build(BuildContext context) {
    final percents = [95, 90, 85, 80, 75, 70, 65, 60];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Training Percentages',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...percents.map((pct) {
            final w = oneRM * pct / 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text('$pct%',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 72,
                    child: Text('${w.toStringAsFixed(1)} kg',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color color;
  final bool isHighlighted;

  const _ResultCard({
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.12)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isHighlighted ? color.withValues(alpha: 0.4) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          if (subtitle != null)
            Text(subtitle!,
                style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String content;
  const _InfoBlock({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.info, size: 16),
              const SizedBox(width: 8),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
