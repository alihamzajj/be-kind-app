import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/notifications/reminder_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/widgets/ui.dart';
import '../home/controllers/daily_controller.dart';

class ReminderSettingsScreen extends ConsumerWidget {
  const ReminderSettingsScreen({super.key});

  static String formatTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m ${hour < 12 ? 'AM' : 'PM'}';
  }

  Future<void> _setEnabled(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    HapticFeedback.selectionClick();
    if (enabled) {
      final granted = await ReminderService.instance.requestPermission();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notifications are blocked. Allow them for Be Kind in '
                'your phone’s Settings.',
              ),
            ),
          );
        }
        return;
      }
    }
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(reminderEnabled: enabled));
  }

  Future<void> _pickCustomTime(
    BuildContext context,
    WidgetRef ref,
    AppSettings s,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute),
    );
    if (picked == null) return;
    await ref
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            reminderHour: picked.hour,
            reminderMinute: picked.minute,
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final task = ref.watch(
      dailyNotifierProvider.select((d) => d.selectedTask ?? d.primaryTask),
    );
    final hPad = pagePadding(context);
    final notifier = ref.read(settingsProvider.notifier);
    const presets = [(7, 0), (8, 0), (9, 0)];
    final isPreset = presets.any(
      (p) => p.$1 == s.reminderHour && p.$2 == s.reminderMinute,
    );
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', //
      'Friday', 'Saturday', 'Sunday',
    ];

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
              children: [
                PageHeader(
                  title: 'Daily reminder',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 18),

                // Preview
                SoftCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.onLime,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.favorite,
                                size: 20,
                                color: AppColors.lime,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Be Kind · '
                                    '${formatTime(s.reminderHour, s.reminderMinute)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Your kind act for today is ready',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    task == null
                                        ? 'Open Be Kind to see today’s act'
                                        : '${task.title} · '
                                              '${task.estimatedMinutes} min',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _SwitchRow(
                  title: 'Remind me every day',
                  subtitle: 'A gentle nudge with that day’s kind act',
                  value: s.reminderEnabled,
                  onChanged: (v) => _setEnabled(context, ref, v),
                ),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: s.reminderEnabled ? 1 : 0.4,
                  child: IgnorePointer(
                    ignoring: !s.reminderEnabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        _Label('Time'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final p in presets)
                              PillChip(
                                label: formatTime(p.$1, p.$2),
                                primary:
                                    s.reminderHour == p.$1 &&
                                    s.reminderMinute == p.$2,
                                onTap: () => notifier.update(
                                  (s) => s.copyWith(
                                    reminderHour: p.$1,
                                    reminderMinute: p.$2,
                                  ),
                                ),
                              ),
                            PillChip(
                              label: isPreset
                                  ? 'Custom'
                                  : formatTime(
                                      s.reminderHour,
                                      s.reminderMinute,
                                    ),
                              icon: Icons.schedule,
                              primary: !isPreset,
                              onTap: () => _pickCustomTime(context, ref, s),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _Label('Days'),
                        Row(
                          children: [
                            for (var i = 0; i < 7; i++) ...[
                              if (i > 0) const SizedBox(width: 6),
                              Expanded(
                                child: _DayToggle(
                                  label: dayLabels[i],
                                  semantic: dayNames[i],
                                  on: s.reminderDays.contains(i + 1),
                                  onTap: () {
                                    final days = {...s.reminderDays};
                                    if (!days.remove(i + 1)) days.add(i + 1);
                                    if (days.isEmpty) return;
                                    notifier.update(
                                      (s) => s.copyWith(
                                        reminderDays: days.toList()..sort(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        _SwitchRow(
                          title: 'Evening nudge',
                          subtitle:
                              'At 7 PM, only if today’s act isn’t done yet',
                          value: s.eveningNudge,
                          onChanged: (v) => notifier.update(
                            (s) => s.copyWith(eveningNudge: v),
                          ),
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: () =>
                              ReminderService.instance.showPreview(task),
                          icon: const Icon(Icons.notifications_outlined),
                          label: const Text('Send a test reminder'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({
    required this.label,
    required this.semantic,
    required this.on,
    required this.onTap,
  });

  final String label;
  final String semantic;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantic,
      toggled: on,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: on ? AppColors.lime : AppColors.card,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: on ? AppColors.onLime : AppColors.inkSoft,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
