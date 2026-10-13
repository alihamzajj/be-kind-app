import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/ui.dart';
import '../home/controllers/daily_controller.dart';
import '../streaks/engine/streak_engine.dart';
import 'widgets/growth_widgets.dart';
import '../../core/widgets/motion.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyNotifierProvider);
    final hPad = pagePadding(context);

    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.track,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      );
    }

    final streak = state.streakResult;
    final now = DateTime.now();

    // Last 7 days, oldest first
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final completedDates = state.allCompletions.map((c) => c.localDate).toSet();
    final week = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return (
        label: dayNames[date.weekday - 1],
        done: completedDates.contains(StreakEngine.formatLocalDate(date)),
        isToday: i == 6,
      );
    });

    final earned = state.badges.where((b) => b.isEarned).length;
    final doneToday = state.todayCompletion != null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Your progress',
            trailing: RoundIconButton(
              icon: Icons.calendar_today_outlined,
              tooltip: 'History',
              onTap: () => context.push('/history'),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PillChip(
                  label: '${streak.currentStreak} day streak',
                  icon: Icons.local_fire_department,
                  primary: true,
                  onTap: null,
                ),
                const SizedBox(width: 8),
                PillChip(
                  label: '$earned of ${state.badges.length} badges',
                  onTap: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Streak card
          SoftCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current streak',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              RollingNumber(
                                value: streak.currentStreak,
                                rollFrom: doneToday && streak.currentStreak > 0
                                    ? streak.currentStreak - 1
                                    : null,
                                style: TextStyle(
                                  fontSize: 56,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                streak.currentStreak == 1 ? 'day' : 'days',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            !doneToday
                                ? 'Do today’s act to keep it burning'
                                : (streak.currentStreak > 1 &&
                                          streak.currentStreak >=
                                              streak.longestStreak
                                      ? 'Your longest streak yet!'
                                      : '+1 today. Nicely done!'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.streak,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreakFlame(size: 88, lit: streak.currentStreak > 0),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final d in week)
                      _DayDot(label: d.label, done: d.done, isToday: d.isToday),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '${streak.longestStreak}',
                  label: 'Longest streak',
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: '${streak.totalCompletedDays}',
                  label: 'Kind days total',
                  icon: Icons.favorite_border,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          const SectionHeader(title: 'Calendar'),
          const SizedBox(height: 12),
          MonthCalendar(
            completedDates: completedDates,
            longestStreak: streak.longestStreak,
          ),
          const SizedBox(height: 30),
          const SectionHeader(title: 'Your growth'),
          const SizedBox(height: 12),
          LevelCard(totalActs: state.allCompletions.length),
          const SizedBox(height: 12),
          WeeklyGoalCard(completedDates: completedDates),
          const SizedBox(height: 30),
          const SectionHeader(title: 'Your kindness mix'),
          const SizedBox(height: 14),
          KindnessMix(completions: state.allCompletions),
          const SizedBox(height: 30),
          const SectionHeader(title: 'Badges'),
          const SizedBox(height: 6),
          for (final b in state.badges)
            ActivityRow(
              icon: b.definition.icon,
              title: b.definition.name,
              subtitle: b.definition.description,
              highlight: b.isEarned,
              dimmed: !b.isEarned,
              trailing: b.isEarned
                  ? 'Earned'
                  : '${b.currentProgress.clamp(0, b.definition.targetCount)} / ${b.definition.targetCount}',
              trailingSub: b.isEarned ? null : 'to go',
            ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.done,
    required this.isToday,
  });

  final String label;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.lime : AppColors.surface,
            border: isToday && !done
                ? Border.all(color: AppColors.accent, width: 1.5)
                : null,
          ),
          child: done
              ? Icon(Icons.check, size: 18, color: AppColors.onLime)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            color: done || isToday ? AppColors.accent : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
