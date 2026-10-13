import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/settings/app_settings.dart';
import '../../core/widgets/ui.dart';
import '../home/controllers/daily_controller.dart';
import 'reminder_settings_screen.dart';

class ProfilePlaceholderScreen extends ConsumerWidget {
  const ProfilePlaceholderScreen({super.key});

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: ref.read(settingsProvider).name ?? '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'First name',
            counterText: '',
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    final name = result.trim();
    await ref
        .read(settingsProvider.notifier)
        .update(
          (s) => name.isEmpty
              ? AppSettings.fromJson({...s.toJson(), 'name': null})
              : s.copyWith(name: name),
        );
  }

  void _pickAppearance(BuildContext context, WidgetRef ref) {
    const options = [
      (
        ThemeMode.system,
        'Automatic',
        'Match your phone',
        Icons.brightness_auto,
      ),
      (ThemeMode.light, 'Light', 'Bright and airy', Icons.light_mode_outlined),
      (ThemeMode.dark, 'Dark', 'Easy on the eyes', Icons.dark_mode_outlined),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Appearance'),
              const SizedBox(height: 8),
              for (final o in options)
                ActivityRow(
                  icon: o.$4,
                  title: o.$2,
                  subtitle: o.$3,
                  highlight: ref.read(settingsProvider).themeMode == o.$1,
                  trailingIcon: ref.read(settingsProvider).themeMode == o.$1
                      ? Icons.check
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(settingsProvider.notifier)
                        .update((s) => s.copyWith(themeMode: o.$1));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyNotifierProvider);
    final settings = ref.watch(settingsProvider);
    const themeLabels = {
      ThemeMode.system: 'Automatic',
      ThemeMode.light: 'Light',
      ThemeMode.dark: 'Dark',
    };
    final hPad = pagePadding(context);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.lineStrong),
                  ),
                  child: Text(
                    settings.initials,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  settings.name?.trim().isNotEmpty == true
                      ? settings.name!.trim()
                      : 'Guest',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    PillChip(
                      label: 'Edit name',
                      icon: Icons.edit_outlined,
                      onTap: () => _editName(context, ref),
                    ),
                    PillChip(
                      label: 'Sign in to back up',
                      primary: true,
                      onTap: () => context.push('/auth'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: '${state.streakResult.currentStreak}',
                  label: 'Day streak',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  value: '${state.allCompletions.length}',
                  label: 'Kind acts',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  value: '${state.badges.where((b) => b.isEarned).length}',
                  label: 'Badges',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Your activity'),
          const SizedBox(height: 4),
          ActivityRow(
            icon: Icons.calendar_today_outlined,
            title: 'Kindness history',
            subtitle: 'View and filter past kind deeds',
            trailingIcon: Icons.chevron_right,
            onTap: () => context.push('/history'),
          ),
          ActivityRow(
            icon: Icons.military_tech_outlined,
            title: 'Progress & badges',
            subtitle: 'Streaks, totals and milestones',
            trailingIcon: Icons.chevron_right,
            onTap: () => context.go('/progress'),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Settings'),
          const SizedBox(height: 4),
          ActivityRow(
            icon: settings.reminderEnabled
                ? Icons.notifications_active_outlined
                : Icons.notifications_none,
            title: 'Daily reminder',
            subtitle: settings.reminderEnabled
                ? 'On · ${ReminderSettingsScreen.formatTime(settings.reminderHour, settings.reminderMinute)}'
                : 'Off · get nudged each morning',
            trailingIcon: Icons.chevron_right,
            onTap: () => context.push('/reminders'),
          ),
          ActivityRow(
            icon: Icons.contrast,
            title: 'Appearance',
            subtitle: themeLabels[settings.themeMode]!,
            trailingIcon: Icons.chevron_right,
            onTap: () => _pickAppearance(context, ref),
          ),
          ActivityRow(
            icon: Icons.shield_outlined,
            title: 'Privacy',
            subtitle: 'Your data stays on this device',
            trailingIcon: Icons.chevron_right,
            onTap: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Local storage & privacy'),
                content: const Text(
                  'Your completed tasks, reflections, and streaks stay on '
                  'this device. Cloud accounts and backup are coming soon.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const MotivationalBanner(),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

/// Dark promo-style card used on Profile and Friends.
class MotivationalBanner extends StatelessWidget {
  const MotivationalBanner({
    this.title = 'Kindness is better together',
    this.body =
        'Invite friends, cheer each other on and share streaks. '
        'Coming soon.',
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.promo,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'COMING SOON',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.onLime,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
