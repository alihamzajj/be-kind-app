import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../home/controllers/daily_controller.dart';
import '../streaks/engine/streak_engine.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

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
            Container(height: 180, decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(24))),
            const SizedBox(height: 20),
            Container(height: 240, decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(20))),
          ],
        ),
      );
    }

    final streak = state.streakResult;
    final now = DateTime.now();

    // Compute the last 7 days statuses
    final List<bool> weekCompleted = [];
    final List<String> weekLabels = [];
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final completedDatesSet = state.allCompletions.map((c) => c.localDate).toSet();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = StreakEngine.formatLocalDate(date);
      weekCompleted.add(completedDatesSet.contains(dateStr));
      weekLabels.add(dayNames[date.weekday - 1]);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
        vertical: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your progress',
            style: isDesktop
                ? textTheme.headlineMedium?.copyWith(fontSize: 34)
                : textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // Streak Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.streakSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: AppColors.streak,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${streak.currentStreak} ${streak.currentStreak == 1 ? "day" : "days"}',
                          style: const TextStyle(
                            fontFamily: 'Bricolage Grotesque',
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          'Current streak',
                          style: TextStyle(fontSize: 14, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 7-day strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (idx) {
                    return _DayDot(
                      dayLabel: weekLabels[idx],
                      completed: weekCompleted[idx],
                    );
                  }),
                ),
                const SizedBox(height: 22),

                // 2 stat tiles on ground bg
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.ground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${streak.longestStreak} days',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Longest streak',
                              style: TextStyle(fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.ground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${streak.totalCompletedDays}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Kind days total',
                              style: TextStyle(fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Badges section
          Text('Badges', style: textTheme.titleMedium),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: isDesktop ? 4 : 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isDesktop ? 0.85 : 0.72,
            children: state.badges.map((b) {
              final statusStr = b.isEarned
                  ? 'Earned'
                  : '${b.currentProgress} / ${b.definition.targetCount}';
              return _BadgeCard(
                name: b.definition.name,
                status: statusStr,
                isEarned: b.isEarned,
                icon: b.definition.icon,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.dayLabel, required this.completed});

  final String dayLabel;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? AppColors.accent : AppColors.track,
          ),
          child: completed
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: completed ? AppColors.accentDark : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.name,
    required this.status,
    required this.isEarned,
    required this.icon,
  });

  final String name;
  final String status;
  final bool isEarned;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEarned ? AppColors.accent.withValues(alpha: 0.3) : AppColors.line,
          width: isEarned ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isEarned
                ? AppColors.accent.withValues(alpha: 0.06)
                : AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned ? AppColors.accentSoft : AppColors.track,
              border: Border.all(
                color: isEarned ? AppColors.accent.withValues(alpha: 0.25) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isEarned ? AppColors.accent : AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isEarned ? AppColors.accentSoft : AppColors.ground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isEarned ? AppColors.accentDark : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
