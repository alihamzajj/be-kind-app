import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:be_kind/app/theme/app_colors.dart';
import 'package:be_kind/features/home/controllers/daily_controller.dart';
import 'package:be_kind/features/home/models/motivational_quote.dart';
import 'package:be_kind/features/home/services/quote_library.dart';
import 'package:be_kind/features/home/widgets/alternatives_sheet.dart';
import 'package:be_kind/features/home/widgets/motivational_quote_card.dart';
import 'package:be_kind/features/kindness_tasks/models/kindness_task.dart';
import 'package:be_kind/features/task_completion/widgets/share_card_sheet.dart';
import 'package:be_kind/core/settings/app_settings.dart';
import 'package:be_kind/core/widgets/motion.dart';
import 'package:be_kind/core/widgets/ui.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  late MotivationalQuote _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = QuoteLibrary.getRandomQuote();
  }

  void _refreshQuote() {
    setState(() {
      _currentQuote = QuoteLibrary.getRandomQuote(_currentQuote);
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _complete(KindnessTask task, int streakCount) {
    context.push(
      '/today/done',
      extra: {'task': task, 'predictedStreak': streakCount + 1},
    );
  }

  void _addNote(KindnessTask task, DailyState state) {
    context.push(
      '/today/done',
      extra: {
        'task': task,
        'predictedStreak': state.streakResult.currentStreak,
        'existingNote': state.todayCompletion?.privateNote,
      },
    );
  }

  void _openSwapSheet(DailyState state) {
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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;
    final hPad = isDesktop ? 32.0 : 20.0;

    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.track,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.track,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      );
    }

    final activeTask = state.selectedTask ?? state.primaryTask;
    final isCompletedToday = state.todayCompletion != null;
    final streakCount = state.streakResult.currentStreak;
    final recent = [...state.allCompletions]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: avatar + streak pill + history shortcut
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                _Avatar(
                  initials: settings.initials,
                  streakActive: streakCount > 0,
                  onTap: () => context.go('/profile'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _Pill(
                      label: '$streakCount day streak',
                      icon: Icons.local_fire_department,
                      onTap: () => context.go('/progress'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                RoundIconButton(
                  icon: Icons.calendar_today_outlined,
                  tooltip: 'History',
                  onTap: () => context.push('/history'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Headline
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${_getGreeting()}, ${settings.displayName}',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: isDesktop ? 36 : 30,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                RoundIconButton(
                  icon: Icons.bar_chart_rounded,
                  tooltip: 'Progress',
                  onTap: () => context.go('/progress'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick actions
          if (activeTask != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Row(
                children: [
                  if (isCompletedToday) ...[
                    PillChip(
                      label: 'Add note',
                      primary: true,
                      onTap: () => _addNote(activeTask, state),
                    ),
                    const SizedBox(width: 8),
                    PillChip(
                      label: 'Share',
                      icon: Icons.ios_share,
                      onTap: () => showShareCardSheet(
                        context,
                        streak: streakCount,
                        taskTitle: activeTask.title,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!isCompletedToday && state.alternatives.isNotEmpty) ...[
                    PillChip(
                      label: 'Swap task',
                      onTap: () => _openSwapSheet(state),
                    ),
                    const SizedBox(width: 8),
                  ],
                  PillChip(
                    label: 'History',
                    onTap: () => context.push('/history'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),

          // Card carousel
          SizedBox(
            height: 196,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: hPad),
              children: [
                if (activeTask != null)
                  _TaskCard(
                    task: activeTask,
                    isDone: isCompletedToday,
                    onTap: isCompletedToday
                        ? () => _addNote(activeTask, state)
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Press and hold \u201cI did it\u201d below '
                                'when you\u2019ve done it',
                              ),
                            ),
                          ),
                  ),
                if (state.badges.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  _BadgeCard(state: state),
                ],
                if (!isCompletedToday && state.alternatives.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  _NewIdeaCard(
                    count: state.alternatives.length,
                    onTap: () => _openSwapSheet(state),
                  ),
                ],
              ],
            ),
          ),
          if (activeTask != null && !isCompletedToday) ...[
            const SizedBox(height: 18),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                children: [
                  HoldToConfirmButton(
                    label: 'Hold: I did it',
                    holdingLabel: 'Keep holding\u2026',
                    onConfirmed: () => _complete(activeTask, streakCount),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Press and hold to mark today\u2019s act as done',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),

          // Recent kind acts
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent kind acts',
                        style: textTheme.headlineSmall?.copyWith(fontSize: 22),
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push('/history'),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  ActivityRow(
                    icon: Icons.add,
                    title: 'Your first kind act',
                    subtitle: 'Complete today’s task to start',
                    trailing: '+1',
                    trailingSub: 'streak',
                    onTap: activeTask == null || isCompletedToday
                        ? null
                        : () => _complete(activeTask, streakCount),
                  )
                else
                  ...recent
                      .take(3)
                      .map(
                        (c) => ActivityRow(
                          icon: categoryIcon(c.category),
                          title: c.taskTitle,
                          subtitle:
                              '${c.category} · ${formatShortDate(c.completedAt)}',
                          trailing: '+1',
                          trailingSub: c.privateNote?.isNotEmpty == true
                              ? 'with note'
                              : 'kind act',
                          onTap: () => context.push('/history'),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 26),

          // Daily inspiration banner
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily inspiration',
                  style: textTheme.headlineSmall?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 12),
                MotivationalQuoteCard(
                  quote: _currentQuote,
                  onRefresh: _refreshQuote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.streakActive,
    required this.onTap,
  });

  final String initials;
  final bool streakActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Profile',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.lineStrong),
                ),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: streakActive ? AppColors.streak : AppColors.muted,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lime,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.onLime),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onLime,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.child, this.onTap, this.dashed = false});

  final Widget child;
  final VoidCallback? onTap;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    final content = Material(
      color: dashed ? AppColors.surface : AppColors.card,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
    return SizedBox(
      width: 210,
      child: dashed
          ? CustomPaint(
              foregroundPainter: _DashedBorderPainter(radius: 22),
              child: content,
            )
          : content,
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.isDone,
    required this.onTap,
  });

  final KindnessTask task;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CarouselCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.lime : AppColors.surface,
                ),
                child: Icon(
                  isDone ? Icons.check : Icons.favorite,
                  size: 18,
                  color: isDone ? AppColors.onLime : AppColors.streak,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.schedule, size: 13, color: AppColors.muted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${task.estimatedMinutes} min · '
                  '${task.moneyRequired ? 'May cost money' : 'Free'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.ink,
            ),
          ),
          if (isDone) ...[
            const SizedBox(height: 6),
            Text(
              'Done for today',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.positive,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.state});

  final DailyState state;

  @override
  Widget build(BuildContext context) {
    final nextBadge = state.badges.firstWhere(
      (b) => !b.isEarned,
      orElse: () => state.badges.first,
    );
    final target = nextBadge.definition.targetCount;
    final progressRatio = (nextBadge.currentProgress / target).clamp(0.0, 1.0);

    return _CarouselCard(
      onTap: () => context.go('/progress'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
                child: Icon(
                  Icons.military_tech,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Next badge',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            nextBadge.definition.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            '${nextBadge.currentProgress} / $target',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 6,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation(AppColors.positive),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewIdeaCard extends StatelessWidget {
  const _NewIdeaCard({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CarouselCard(
      dashed: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lineStrong),
                ),
                child: Icon(Icons.add, color: AppColors.ink),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'New idea',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Not feeling this one? Swap to one of $count other kind acts.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lineStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(0.75),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
