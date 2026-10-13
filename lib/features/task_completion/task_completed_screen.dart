import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/ui.dart';
import '../achievements/models/badge_models.dart';
import '../home/controllers/daily_controller.dart';
import '../kindness_tasks/models/kindness_task.dart';
import 'widgets/celebration_view.dart';
import 'widgets/share_card_sheet.dart';

class TaskCompletedScreen extends ConsumerStatefulWidget {
  const TaskCompletedScreen({
    this.task,
    this.predictedStreak = 1,
    this.existingNote,
    super.key,
  });

  final KindnessTask? task;
  final int predictedStreak;
  final String? existingNote;

  @override
  ConsumerState<TaskCompletedScreen> createState() =>
      _TaskCompletedScreenState();
}

class _TaskCompletedScreenState extends ConsumerState<TaskCompletedScreen> {
  late final TextEditingController _noteController;
  bool _shareWithFriends = false;
  bool _isSaving = false;
  ({int streak, BadgeDefinition? badge})? _celebration;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.existingNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final notifier = ref.read(dailyNotifierProvider.notifier);
    final before = ref.read(dailyNotifierProvider);
    final wasDoneAlready = before.todayCompletion != null;
    final earnedBefore = before.badges
        .where((b) => b.isEarned)
        .map((b) => b.definition.id)
        .toSet();
    try {
      await notifier.completeTodayTask(
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      );
      if (!mounted) return;
      if (wasDoneAlready) {
        // Just updating the note: no second celebration.
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Note saved')));
        context.go('/today');
        return;
      }
      final after = ref.read(dailyNotifierProvider);
      final newlyEarned = after.badges
          .where((b) => b.isEarned && !earnedBefore.contains(b.definition.id))
          .map((b) => b.definition)
          .toList();
      setState(() {
        _celebration = (
          streak: after.streakResult.currentStreak,
          badge: newlyEarned.isEmpty ? null : newlyEarned.first,
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;
    final celebration = _celebration;

    if (celebration != null) {
      return Scaffold(
        backgroundColor: AppColors.ground,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: CelebrationView(
                streak: celebration.streak,
                taskTitle: widget.task?.title ?? 'You did a kind act today.',
                newBadge: celebration.badge,
                onContinue: () => context.go('/today'),
                onShare: widget.task == null
                    ? null
                    : () => showShareCardSheet(
                        context,
                        streak: celebration.streak,
                        taskTitle: widget.task!.title,
                      ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 20,
            vertical: 20,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    label: 'Back to today',
                    child: RoundIconButton(
                      icon: Icons.arrow_back,
                      tooltip: 'Back',
                      size: 20,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Success icon & headline
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lime,
                    ),
                    child: Icon(Icons.check, size: 52, color: AppColors.onLime),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Nicely done.',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 34,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    "That's day ${widget.predictedStreak} in a row.",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.inkSoft,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Completed task title recap
                if (widget.task != null)
                  SoftCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                          ),
                          child: Icon(
                            categoryIcon(widget.task!.category),
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.task!.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Private reflection note
                Text(
                  'How did it go? (optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'A quick private reflection on how it felt...',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: AppColors.muted),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Only you can see notes.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Share toggle
                SoftCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share with friends',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Shows the task only, never your note',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _shareWithFriends,
                        onChanged: (val) {
                          setState(() {
                            _shareWithFriends = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sharing with friends is coming soon',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                FilledButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
