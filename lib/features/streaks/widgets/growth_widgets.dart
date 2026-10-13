import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ui.dart';
import '../../task_completion/models/task_completion.dart';
import '../engine/streak_engine.dart';

/// Month grid with done days filled in lime and today ringed.
class MonthCalendar extends StatefulWidget {
  const MonthCalendar({
    required this.completedDates,
    required this.longestStreak,
    super.key,
  });

  /// Local dates (YYYY-MM-DD) with a completed kind act.
  final Set<String> completedDates;
  final int longestStreak;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _shift(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCurrent = _month.year == now.year && _month.month == now.month;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = DateTime(_month.year, _month.month).weekday - 1;

    var doneThisMonth = 0;
    var elapsed = 0;
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_month.year, _month.month, d);
      if (!date.isAfter(today)) elapsed++;
      if (widget.completedDates.contains(StreakEngine.formatLocalDate(date))) {
        doneThisMonth++;
      }
    }
    final pct = elapsed == 0 ? 0 : (doneThisMonth * 100 / elapsed).round();

    return Column(
      children: [
        SoftCard(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatMonthYear(_month),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.chevron_left,
                    tooltip: 'Previous month',
                    onTap: () => _shift(-1),
                  ),
                  const SizedBox(width: 6),
                  _NavButton(
                    icon: Icons.chevron_right,
                    tooltip: 'Next month',
                    onTap: isCurrent ? null : () => _shift(1),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final l in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                    Expanded(
                      child: Center(
                        child: Text(
                          l,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  for (var i = 0; i < leading; i++) const SizedBox.shrink(),
                  for (var d = 1; d <= daysInMonth; d++)
                    _DayCell(
                      day: d,
                      done: widget.completedDates.contains(
                        StreakEngine.formatLocalDate(
                          DateTime(_month.year, _month.month, d),
                        ),
                      ),
                      isToday: isCurrent && d == now.day,
                      isFuture: DateTime(
                        _month.year,
                        _month.month,
                        d,
                      ).isAfter(today),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Legend(
                    swatch: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lime,
                      ),
                    ),
                    label: 'Kind act done',
                  ),
                  const SizedBox(width: 16),
                  _Legend(
                    swatch: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                    ),
                    label: 'Today',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniTile(value: '$doneThisMonth', label: 'This month'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniTile(
                value: '${widget.longestStreak}',
                label: 'Best streak',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniTile(value: '$pct%', label: 'Days kind'),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 20,
              color: onTap == null ? AppColors.lineStrong : AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.done,
    required this.isToday,
    required this.isFuture,
  });

  final int day;
  final bool done;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? AppColors.lime
            : (isFuture ? Colors.transparent : AppColors.surface),
        border: isToday ? Border.all(color: AppColors.accent, width: 2) : null,
      ),
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 13,
          fontWeight: done || isToday ? FontWeight.w800 : FontWeight.w600,
          color: done
              ? AppColors.onLime
              : (isFuture ? AppColors.lineStrong : AppColors.ink),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.swatch, required this.label});

  final Widget swatch;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
      ],
    );
  }
}

class _MiniTile extends StatelessWidget {
  const _MiniTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: AppColors.ink,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Growth levels by total kind acts.
class KindnessLevel {
  const KindnessLevel(this.number, this.name, this.minActs, this.icon);

  final int number;
  final String name;
  final int minActs;
  final IconData icon;

  static const all = [
    KindnessLevel(1, 'Seedling', 0, Icons.grass),
    KindnessLevel(2, 'Sprout', 5, Icons.eco_outlined),
    KindnessLevel(3, 'Bloom', 10, Icons.local_florist_outlined),
    KindnessLevel(4, 'Tree', 20, Icons.park_outlined),
    KindnessLevel(5, 'Forest', 40, Icons.forest_outlined),
  ];

  static KindnessLevel forActs(int acts) =>
      all.lastWhere((l) => acts >= l.minActs);
}

class LevelCard extends StatelessWidget {
  const LevelCard({required this.totalActs, super.key});

  final int totalActs;

  @override
  Widget build(BuildContext context) {
    final level = KindnessLevel.forActs(totalActs);
    final idx = KindnessLevel.all.indexOf(level);
    final next = idx + 1 < KindnessLevel.all.length
        ? KindnessLevel.all[idx + 1]
        : null;
    final ratio = next == null
        ? 1.0
        : (totalActs - level.minActs) / (next.minActs - level.minActs);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.promo,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lime,
                ),
                child: Icon(level.icon, color: AppColors.onLime, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEVEL ${level.number}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.lime,
                    ),
                  ),
                  Text(
                    level.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation(AppColors.lime),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            next == null
                ? 'Top level reached. You’re a kindness Forest!'
                : '$totalActs of ${next.minActs} kind acts to reach ${next.name}',
            style: const TextStyle(fontSize: 13, color: Color(0xFFE6D3D6)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final l in KindnessLevel.all)
                Expanded(
                  child: Text(
                    l.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: l.number < level.number
                          ? AppColors.lime
                          : (l == level
                                ? Colors.white
                                : const Color(0xFFB9A3A7)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ring showing kind acts done this week (Mon–Sun) against a goal.
class WeeklyGoalCard extends StatelessWidget {
  const WeeklyGoalCard({
    required this.completedDates,
    this.goal = 5,
    super.key,
  });

  final Set<String> completedDates;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    var done = 0;
    for (var i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      if (completedDates.contains(StreakEngine.formatLocalDate(d))) done++;
    }
    final left = math.max(goal - done, 0);

    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: (done / goal).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
                Text(
                  '$done/$goal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  left == 0
                      ? 'Goal reached this week. Wonderful!'
                      : '$left more kind ${left == 1 ? 'act' : 'acts'} this '
                            'week to hit your goal.',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal bars per category plus a nudge toward the least-tried one.
class KindnessMix extends StatelessWidget {
  const KindnessMix({required this.completions, super.key});

  final List<TaskCompletion> completions;

  static const categories = [
    'Gratitude',
    'Community',
    'Environment',
    'Helping someone',
    'Self-kindness',
    'Family & Friends',
    'Inclusion',
  ];

  @override
  Widget build(BuildContext context) {
    final counts = {for (final c in categories) c: 0};
    for (final c in completions) {
      counts[c.category] = (counts[c.category] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = math.max(sorted.first.value, 1);
    final least = sorted.last.key;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, e) in sorted.indexed) ...[
          Row(
            children: [
              Icon(categoryIcon(e.key), size: 16, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                '${e.value}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: e.value == 0 ? 0.02 : e.value / max,
              minHeight: 10,
              backgroundColor: AppColors.card,
              valueColor: AlwaysStoppedAnimation(
                i == 0 && e.value > 0 ? AppColors.accent : AppColors.lime,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            sorted.first.value == 0
                ? 'Complete a few kind acts to see your strengths.'
                : 'You’re strongest at ${sorted.first.key}. '
                      'Try a $least act this week.',
            style: TextStyle(fontSize: 13, color: AppColors.ink, height: 1.4),
          ),
        ),
      ],
    );
  }
}
