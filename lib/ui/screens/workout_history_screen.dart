import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/workout_provider.dart';
import '../../providers/user_provider.dart';
import '../../data/model/models.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final units = context.watch<UserProvider>().profile.unitSystem;

    return Scaffold(
      appBar: const FitFudgeAppBar(title: 'History'),
      body: provider.sessions.isEmpty
          ? const EmptyState(
              icon: Icons.history_outlined,
              title: 'No Workouts Yet',
              message: 'Your completed workouts will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: provider.sessions.length,
              itemBuilder: (context, i) => _SessionCard(
                session: provider.sessions[i],
                units: units,
                onDelete: () => _confirmDelete(
                    context, provider, provider.sessions[i]),
                onTap: () => _showDetail(
                    context, provider, provider.sessions[i], units),
              ),
            ),
    );
  }

  void _confirmDelete(
      BuildContext context, WorkoutProvider provider, WorkoutSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Session'),
        content: const Text('This session and all its set records will be deleted permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteSession(session.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, WorkoutProvider provider,
      WorkoutSession session, UnitSystem units) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SessionDetailScreen(
          session: session,
          units: units,
        ),
      ),
    );
  }
}

// ─── Session Card ─────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final WorkoutSession session;
  final UnitSystem units;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.units,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE, MMM d · h:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(session.startTime));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.templateName,
                          style: Theme.of(context).textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(date,
                          style: Theme.of(context).textTheme.bodySmall),
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
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(
                    label: 'Duration',
                    value: formatDuration(session.durationSeconds),
                    icon: Icons.timer_outlined),
                _Stat(
                    label: 'Sets',
                    value: '${session.totalSets}',
                    icon: Icons.fitness_center),
                _Stat(
                    label: 'Reps',
                    value: '${session.totalReps}',
                    icon: Icons.repeat),
                _Stat(
                    label: 'Volume',
                    value: formatWeight(session.totalVolumeKg, units),
                    icon: Icons.bar_chart),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Stat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 16),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── Session Detail ───────────────────────────────────────────────────────────

class _SessionDetailScreen extends StatefulWidget {
  final WorkoutSession session;
  final UnitSystem units;

  const _SessionDetailScreen(
      {required this.session, required this.units});

  @override
  State<_SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<_SessionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, MMMM d, y').format(
        DateTime.fromMillisecondsSinceEpoch(widget.session.startTime));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(widget.session.templateName,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            // Summary grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                StatCard(
                  label: 'Duration',
                  value: formatDuration(widget.session.durationSeconds),
                  icon: Icons.timer_outlined,
                ),
                StatCard(
                  label: 'Total Sets',
                  value: '${widget.session.totalSets}',
                  icon: Icons.fitness_center,
                ),
                StatCard(
                  label: 'Total Reps',
                  value: '${widget.session.totalReps}',
                  icon: Icons.repeat,
                ),
                StatCard(
                  label: 'Volume',
                  value: formatWeight(widget.session.totalVolumeKg, widget.units),
                  icon: Icons.bar_chart,
                ),
              ],
            ),

            if (widget.session.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notes',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(widget.session.notes,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
