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
    final hPad = pagePadding(context);

    if (state.isLoading) return _LoadingSkeleton(hPad: hPad);

    final activeTask = state.selectedTask ?? state.primaryTask;
    final isCompletedToday = state.todayCompletion != null;
    final streakCount = state.streakResult.currentStreak;

    final sections = <Widget>[
      _Header(
        date: formatShortDate(DateTime.now()),
        greeting: '${_getGreeting()}, ${settings.displayName}',
        subtitle: isCompletedToday
            ? 'You made someone’s day a little brighter.'
            : 'One small act of kindness is all it takes.',
        initials: settings.initials,
        onProfile: () => context.go('/profile'),
      ),

      // Today's task: the one thing this screen is about.
      if (activeTask != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TodayTaskCard(
              task: activeTask,
              isDone: isCompletedToday,
              onSwap: !isCompletedToday && state.alternatives.isNotEmpty
                  ? () => _openSwapSheet(state)
                  : null,
              onAddNote: () => _addNote(activeTask, state),
              onShare: () => showShareCardSheet(
                context,
                streak: streakCount,
                taskTitle: activeTask.title,
              ),
            ),
            if (!isCompletedToday) ...[
              const SizedBox(height: 14),
              HoldToConfirmButton(
                label: 'Hold: I did it',
                holdingLabel: 'Keep holding…',
                color: AppColors.accentSoft,
                onConfirmed: () => _complete(activeTask, streakCount),
              ),
              const SizedBox(height: 8),
              Text(
                'Press and hold once you’ve done it',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ],
        ),

      // At-a-glance progress; both tiles open the Progress tab.
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StreakTile(
                streak: streakCount,
                onTap: () => context.go('/progress'),
              ),
            ),
            if (state.badges.isNotEmpty) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _BadgeTile(
                  state: state,
                  onTap: () => context.go('/progress'),
                ),
              ),
            ],
          ],
        ),
      ),

      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Daily inspiration'),
          const SizedBox(height: 12),
          MotivationalQuoteCard(quote: _currentQuote, onRefresh: _refreshQuote),
        ],
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                if (i > 0) SizedBox(height: i == 1 ? 20 : 28),
                _Reveal(index: i, child: sections[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades and lifts each section in, one after another.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    final delay = index * 0.12;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 70),
      curve: Interval(delay.clamp(0.0, 0.6), 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.date,
    required this.greeting,
    required this.subtitle,
    required this.initials,
    required this.onProfile,
  });

  final String date;
  final String greeting;
  final String subtitle;
  final String initials;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                greeting,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: isDesktop ? 34 : 28, height: 1.12),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14.5, color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _Avatar(initials: initials, onTap: onProfile),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.onTap});

  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Profile',
      child: Material(
        color: AppColors.lime,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onLime,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The hero: today's kind act in full, on a deep green card.
class _TodayTaskCard extends StatelessWidget {
  const _TodayTaskCard({
    required this.task,
    required this.isDone,
    required this.onSwap,
    required this.onAddNote,
    required this.onShare,
  });

  final KindnessTask task;
  final bool isDone;
  final VoidCallback? onSwap;
  final VoidCallback onAddNote;
  final VoidCallback onShare;

  static const _bg = AppColors.onLime;
  static const _fg = Colors.white;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.palette.brightness == Brightness.dark;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(28),
        border: dark
            ? Border.all(color: AppColors.lime.withValues(alpha: 0.18))
            : null,
      ),
      child: Stack(
        children: [
          // Soft lime glows for depth.
          Positioned(
            right: -50,
            top: -60,
            child: _Glow(size: 190, alpha: 0.13),
          ),
          Positioned(
            left: -40,
            bottom: -70,
            child: _Glow(size: 150, alpha: 0.07),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _LimeTag(
                          icon: categoryIcon(task.category),
                          label: task.category,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isDone)
                      const _GhostPill(icon: Icons.check_circle, label: 'Done')
                    else if (onSwap != null)
                      _GhostPill(
                        icon: Icons.shuffle_rounded,
                        label: 'Swap',
                        onTap: onSwap,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  isDone ? 'Today’s kind act · done' : 'Today’s kind act',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lime.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: _fg,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      color: _fg.withValues(alpha: 0.78),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.schedule_rounded,
                      label: '${task.estimatedMinutes} min',
                    ),
                    _MetaChip(
                      icon: task.moneyRequired
                          ? Icons.payments_outlined
                          : Icons.favorite_border_rounded,
                      label: task.moneyRequired ? 'May cost a little' : 'Free',
                    ),
                    _MetaChip(icon: Icons.bolt_rounded, label: task.difficulty),
                  ],
                ),
                if (isDone) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _CardButton(
                          icon: Icons.edit_note_rounded,
                          label: 'Add a note',
                          primary: true,
                          onTap: onAddNote,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CardButton(
                          icon: Icons.ios_share,
                          label: 'Share',
                          onTap: onShare,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lime.withValues(alpha: alpha),
      ),
    );
  }
}

class _LimeTag extends StatelessWidget {
  const _LimeTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: const ShapeDecoration(
        color: AppColors.lime,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.onLime),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.onLime,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Translucent white pill for actions sitting on the green card.
class _GhostPill extends StatelessWidget {
  const _GhostPill({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.lime),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
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
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? AppColors.onLime : Colors.white;
    return Material(
      color: primary ? AppColors.lime : Colors.white.withValues(alpha: 0.12),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fg,
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

/// Small tappable summary tile: icon, big number, caption.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.leading,
    required this.value,
    required this.label,
    required this.onTap,
    this.footer,
  });

  final Widget leading;
  final String value;
  final String label;
  final VoidCallback onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leading,
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.muted,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          if (footer != null) ...[
            const Spacer(),
            const SizedBox(height: 10),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _StreakTile extends StatelessWidget {
  const _StreakTile({required this.streak, required this.onTap});

  final int streak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _StatTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.streakSoft,
        ),
        child: StreakFlame(size: 22, lit: streak > 0),
      ),
      value: streak == 1 ? '1 day' : '$streak days',
      label: streak == 0 ? 'Start your streak today' : 'Current streak',
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.state, required this.onTap});

  final DailyState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badges = state.badges;
    final next = badges.where((b) => !b.isEarned).firstOrNull;
    final earned = badges.where((b) => b.isEarned).length;

    final String value;
    final String label;
    final double ratio;
    if (next == null) {
      value = '$earned/${badges.length}';
      label = 'All badges earned';
      ratio = 1;
    } else {
      final target = next.definition.targetCount;
      value = '${next.currentProgress.clamp(0, target)}/$target';
      label = 'Next: ${next.definition.name}';
      ratio = (next.currentProgress / target).clamp(0.0, 1.0);
    }

    return _StatTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accentSoft,
        ),
        child: Icon(
          next?.definition.icon ?? Icons.military_tech,
          size: 20,
          color: AppColors.accent,
        ),
      ),
      value: value,
      label: label,
      footer: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: ratio,
          minHeight: 6,
          backgroundColor: AppColors.surface,
          valueColor: AlwaysStoppedAnimation(AppColors.positive),
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({required this.hPad});

  final double hPad;

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double radius = 24, double? width}) =>
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.track,
            borderRadius: BorderRadius.circular(radius),
          ),
        );
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          block(12, radius: 6, width: 90),
          const SizedBox(height: 10),
          block(30, radius: 10, width: 240),
          const SizedBox(height: 24),
          block(260, radius: 28),
          const SizedBox(height: 14),
          block(60, radius: 999),
        ],
      ),
    );
  }
}
