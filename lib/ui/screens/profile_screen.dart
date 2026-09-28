import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../data/calculator/fitness_calculator.dart';
import '../../data/model/models.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'calculator_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final profile = provider.profile;
    final account = provider.account;

    return Scaffold(
      appBar: FitFudgeAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditSheet(context, profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account card
            _AccountCard(account: account, profile: profile),
            const SizedBox(height: 20),

            // Stats card
            _StatsCard(profile: profile),
            const SizedBox(height: 20),

            // Settings
            const SectionHeader(title: 'Settings'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.calculate_outlined,
              title: 'Calculators',
              subtitle: 'TDEE, macros, 1RM',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CalculatorScreen()),
              ),
            ),

            _SettingsTile(
              icon: Icons.straighten_outlined,
              title: 'Unit System',
              subtitle: profile.unitSystem == UnitSystem.metric
                  ? 'Metric (kg, cm)'
                  : 'Imperial (lbs, ft)',
              trailing: Switch(
                value: profile.unitSystem == UnitSystem.imperial,
                onChanged: (v) => provider.updateProfileField(
                  unitSystem:
                      v ? UnitSystem.imperial : UnitSystem.metric,
                ),
              ),
            ),

            _SettingsTile(
              icon: Icons.flag_outlined,
              title: 'Fitness Goal',
              subtitle: profile.fitnessGoal.label,
              onTap: () => _showGoalPicker(context, provider, profile),
            ),

            _SettingsTile(
              icon: Icons.directions_run_outlined,
              title: 'Activity Level',
              subtitle: profile.activityLevel.label,
              onTap: () =>
                  _showActivityPicker(context, provider, profile),
            ),

            const SizedBox(height: 20),
            const SectionHeader(title: 'About'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.info_outline,
              title: 'FitFudge',
              subtitle: 'Version 1.0.0',
            ),

            _SettingsTile(
              icon: Icons.fitness_center,
              title: 'Elite Athletic Training & Performance',
              subtitle: 'Built with Flutter',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditProfileSheet(profile: profile),
    );
  }

  void _showGoalPicker(
      BuildContext context, UserProvider provider, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PickerSheet<FitnessGoal>(
        title: 'Fitness Goal',
        values: FitnessGoal.values,
        selected: profile.fitnessGoal,
        labelOf: (g) => g.label,
        onSelect: (g) => provider.updateProfileField(fitnessGoal: g),
      ),
    );
  }

  void _showActivityPicker(
      BuildContext context, UserProvider provider, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PickerSheet<ActivityLevel>(
        title: 'Activity Level',
        values: ActivityLevel.values,
        selected: profile.activityLevel,
        labelOf: (a) => a.label,
        onSelect: (a) => provider.updateProfileField(activityLevel: a),
      ),
    );
  }
}

// ─── Account Card ─────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final UserAccount account;
  final UserProfile profile;
  const _AccountCard({required this.account, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty
                    ? profile.name[0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name,
                    style: Theme.of(context).textTheme.headlineMedium),
                Text(account.email,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    account.membershipTier,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
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

// ─── Stats Card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final UserProfile profile;
  const _StatsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final bmi = FitnessCalculator.calculateBMI(
        profile.weightKg, profile.heightCm);
    final bmr = FitnessCalculator.calculateBMR(profile);
    final tdee = FitnessCalculator.calculateTDEE(profile);

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
            children: [
              _Metric(
                label: 'Age',
                value: '${profile.age}',
                unit: 'yrs',
              ),
              _Metric(
                label: 'Height',
                value: profile.unitSystem == UnitSystem.metric
                    ? profile.heightCm.toStringAsFixed(0)
                    : FitnessCalculator.cmToFeetInches(profile.heightCm),
                unit: profile.unitSystem == UnitSystem.metric ? 'cm' : '',
              ),
              _Metric(
                label: 'Weight',
                value: profile.unitSystem == UnitSystem.metric
                    ? profile.weightKg.toStringAsFixed(1)
                    : FitnessCalculator.kgToLbs(profile.weightKg)
                        .toStringAsFixed(1),
                unit: profile.unitSystem == UnitSystem.metric ? 'kg' : 'lbs',
              ),
              _Metric(
                label: 'BMI',
                value: bmi.toStringAsFixed(1),
                unit: FitnessCalculator.bmiCategory(bmi),
              ),
            ],
          ),
          const Divider(color: AppColors.divider, height: 24),
          Row(
            children: [
              _Metric(
                label: 'BMR',
                value: bmr.round().toString(),
                unit: 'kcal',
              ),
              _Metric(
                label: 'TDEE',
                value: tdee.round().toString(),
                unit: 'kcal',
              ),
              _Metric(
                label: 'Goal',
                value: profile.fitnessGoal.label.split(' ').first,
                unit: '',
              ),
              _Metric(
                label: 'Gender',
                value: profile.gender.name[0].toUpperCase() +
                    profile.gender.name.substring(1),
                unit: '',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _Metric(
      {required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          if (unit.isNotEmpty)
            Text(unit,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.textPrimary)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted))
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right,
                    color: AppColors.textMuted)
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Edit Profile Sheet ───────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  const _EditProfileSheet({required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late Gender _gender;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.profile.name);
    _ageCtrl =
        TextEditingController(text: widget.profile.age.toString());
    _heightCtrl = TextEditingController(
        text: widget.profile.heightCm.toStringAsFixed(1));
    _weightCtrl = TextEditingController(
        text: widget.profile.weightKg.toStringAsFixed(1));
    _gender = widget.profile.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
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
            Text('Edit Profile',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _heightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Height (cm)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Weight (kg)'),
            ),
            const SizedBox(height: 12),
            Text('Gender',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: Gender.values.map((g) {
                final selected = _gender == g;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = g),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Text(
                        g.name[0].toUpperCase() +
                            g.name.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.normal),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final h = double.tryParse(_heightCtrl.text);
                  final w = double.tryParse(_weightCtrl.text);
                  final a = int.tryParse(_ageCtrl.text);
                  if (h == null || w == null || a == null) return;
                  context.read<UserProvider>().updateProfileField(
                        name: _nameCtrl.text.trim(),
                        age: a,
                        gender: _gender,
                        heightCm: h,
                        weightKg: w,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Generic Picker Sheet ─────────────────────────────────────────────────────

class _PickerSheet<T> extends StatelessWidget {
  final String title;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final void Function(T) onSelect;

  const _PickerSheet({
    required this.title,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

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
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...values.map((v) {
            final isSelected = v == selected;
            return GestureDetector(
              onTap: () {
                onSelect(v);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(labelOf(v),
                          style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal)),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
