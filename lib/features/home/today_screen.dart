import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:be_kind/app/theme/app_colors.dart';
import 'package:be_kind/features/home/controllers/daily_controller.dart';
import 'package:be_kind/features/home/widgets/alternatives_sheet.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyNotifierProvider);
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;

    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(height: 50, decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 20),
            Container(height: 240, decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(24))),
          ],
        ),
      );
    }

    final activeTask = state.selectedTask ?? state.primaryTask;
    final isCompletedToday = state.todayCompletion != null;
    final streakCount = state.streakResult.currentStreak;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
        vertical: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_getGreeting()}, Friend',
                    style: isDesktop
                        ? textTheme.headlineMedium?.copyWith(fontSize: 34)
                        : textTheme.headlineMedium,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.streakSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: AppColors.streak, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$streakCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.streak,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Main Task Card
          if (activeTask != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TODAY'S KIND ACT",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.08 * 13,
                          color: AppColors.accent,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          activeTask.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentOnSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    activeTask.title,
                    style: isDesktop
                        ? textTheme.headlineSmall?.copyWith(fontSize: 32)
                        : textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeTask.description,
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(icon: Icons.schedule, label: '${activeTask.estimatedMinutes} min'),
                      _MetaChip(icon: Icons.signal_cellular_alt, label: activeTask.difficulty),
                      _MetaChip(
                        icon: Icons.savings_outlined,
                        label: activeTask.moneyRequired ? 'May cost money' : 'No money needed',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (!isCompletedToday)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              context.push(
                                '/today/done',
                                extra: {
                                  'task': activeTask,
                                  'predictedStreak': streakCount + 1,
                                },
                              );
                            },
                            child: const Text('I did it'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => AlternativesSheet(
                                alternatives: state.alternatives,
                                onSelect: (selected) {
                                  Navigator.pop(ctx);
                                  ref.read(dailyNotifierProvider.notifier).swapTask(selected);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Swapped to: ${selected.title}')),
                                  );
                                },
                              ),
                            );
                          },
                          child: const Text('Swap task'),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.accent, size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Done for today! Beautiful job.',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentDark,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(
                                '/today/done',
                                extra: {
                                  'task': activeTask,
                                  'predictedStreak': streakCount,
                                  'existingNote': state.todayCompletion?.privateNote,
                                },
                              );
                            },
                            child: const Text('Add note'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Next Badge Card
          _NextBadgeCard(state: state),
          const SizedBox(height: 24),

          // Other ideas for today
          if (state.alternatives.isNotEmpty) ...[
            Text('Other ideas for today', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            ...state.alternatives.take(2).map((alt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuickIdeaRow(
                  title: alt.title,
                  subtitle: '${alt.category} · ${alt.estimatedMinutes} min',
                  icon: alt.moneyRequired ? Icons.attach_money : Icons.favorite_border,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Select this task?'),
                        content: Text('Do you want to switch your daily task to:\n"${alt.title}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(dailyNotifierProvider.notifier).swapTask(alt);
                            },
                            child: const Text('Select'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _NextBadgeCard extends StatelessWidget {
  const _NextBadgeCard({required this.state});

  final DailyState state;

  @override
  Widget build(BuildContext context) {
    final nextBadge = state.badges.firstWhere(
      (b) => !b.isEarned,
      orElse: () => state.badges.first,
    );

    final progressRatio = (nextBadge.currentProgress / nextBadge.definition.targetCount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next badge: ${nextBadge.definition.name}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '${nextBadge.currentProgress} / ${nextBadge.definition.targetCount}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 10,
              backgroundColor: AppColors.track,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextBadge.definition.description,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickIdeaRow extends StatelessWidget {
  const _QuickIdeaRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
