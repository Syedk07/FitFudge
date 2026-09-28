import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../data/model/models.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'active_workout_screen.dart';

class WorkoutTemplatesScreen extends StatelessWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: FitFudgeAppBar(
        title: 'Workouts',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateSheet(context),
          ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingOverlay()
          : provider.templates.isEmpty
              ? EmptyState(
                  icon: Icons.list_alt_outlined,
                  title: 'No Workout Plans',
                  message: 'Create your first workout template to get started.',
                  buttonLabel: 'Create Template',
                  onButton: () => _showCreateSheet(context),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: provider.templates.length,
                  itemBuilder: (context, i) {
                    return _TemplateCard(
                      template: provider.templates[i],
                      onStart: () =>
                          _startWorkout(context, provider.templates[i]),
                      onEdit: () =>
                          _showEditSheet(context, provider.templates[i]),
                      onDelete: () => _confirmDelete(
                          context, provider, provider.templates[i]),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _startWorkout(BuildContext context, WorkoutTemplate template) {
    final exerciseProvider = context.read<ExerciseProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    if (workoutProvider.isWorkoutActive) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Workout In Progress'),
          content: const Text(
              'You already have an active workout. Return to it or cancel it first.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK')),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ActiveWorkoutScreen()),
                );
              },
              child: const Text('Return to Workout'),
            ),
          ],
        ),
      );
      return;
    }

    // Resolve exercise objects from IDs
    final ids = template.exerciseIdsJson
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final exercises = ids
        .map((id) => exerciseProvider.getById(id))
        .whereType<Exercise>()
        .toList();

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No valid exercises in this template.'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    workoutProvider.startWorkout(template, exercises);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _TemplateFormSheet(),
    );
  }

  void _showEditSheet(BuildContext context, WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TemplateFormSheet(template: template),
    );
  }

  void _confirmDelete(
      BuildContext context, WorkoutProvider provider, WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Template'),
        content:
            Text('Delete "${template.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteTemplate(template.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Template Card ────────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TemplateCard({
    required this.template,
    required this.onStart,
    required this.onEdit,
    required this.onDelete,
  });

  int get _exerciseCount =>
      template.exerciseIdsJson
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .length;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        MuscleChip(label: template.targetFocus),
                        const SizedBox(width: 8),
                        Text(
                          '$_exerciseCount exercise${_exerciseCount == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.surfaceElevated,
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textMuted),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined,
                            color: AppColors.textSecondary, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ])),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: AppColors.error)),
                      ])),
                ],
              ),
            ],
          ),
          if (template.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(template.notes,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Start Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Template Form Sheet ─────────────────────────────────────────────────────

class _TemplateFormSheet extends StatefulWidget {
  final WorkoutTemplate? template;
  const _TemplateFormSheet({this.template});

  @override
  State<_TemplateFormSheet> createState() => _TemplateFormSheetState();
}

class _TemplateFormSheetState extends State<_TemplateFormSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _focusCtrl;
  late TextEditingController _notesCtrl;
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.template?.name ?? '');
    _focusCtrl =
        TextEditingController(text: widget.template?.targetFocus ?? '');
    _notesCtrl = TextEditingController(text: widget.template?.notes ?? '');
    _selectedIds = widget.template != null
        ? widget.template!.exerciseIdsJson
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList()
        : [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _focusCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = context.read<ExerciseProvider>().allExercises;
    final isEdit = widget.template != null;

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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(isEdit ? 'Edit Template' : 'New Template',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Workout Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _focusCtrl,
              decoration:
                  const InputDecoration(labelText: 'Target Focus (e.g. Chest)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration:
                  const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text('Select Exercises',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...exercises.map((ex) {
              final selected = _selectedIds.contains(ex.id);
              return CheckboxListTile(
                value: selected,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedIds.add(ex.id);
                    } else {
                      _selectedIds.remove(ex.id);
                    }
                  });
                },
                title: Text(ex.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary)),
                subtitle: Text(ex.primaryMuscle,
                    style: Theme.of(context).textTheme.bodySmall),
                activeColor: AppColors.secondary,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameCtrl.text.trim().isEmpty) return;
                  final provider = context.read<WorkoutProvider>();
                  final template = WorkoutTemplate(
                    id: widget.template?.id ?? 0,
                    name: _nameCtrl.text.trim(),
                    targetFocus: _focusCtrl.text.trim(),
                    exerciseIdsJson: _selectedIds.join(','),
                    notes: _notesCtrl.text.trim(),
                    createdAt: widget.template?.createdAt ??
                        DateTime.now().millisecondsSinceEpoch,
                  );
                  if (isEdit) {
                    provider.updateTemplate(template);
                  } else {
                    provider.addTemplate(template);
                  }
                  Navigator.pop(context);
                },
                child: Text(isEdit ? 'Save Changes' : 'Create Template'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
