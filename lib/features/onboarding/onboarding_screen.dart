import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/notifications/reminder_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/widgets/ui.dart';

/// Three-step intro: what the app does, how progress works, and your name.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  final _name = TextEditingController();
  int _page = 0;
  bool _reminder = true;
  bool _saving = false;

  static const _count = 3;

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish({bool skipped = false}) async {
    if (_saving) return;
    setState(() => _saving = true);
    HapticFeedback.selectionClick();
    final name = _name.text.trim();
    final wantsReminder = !skipped && _reminder;
    var granted = false;
    if (wantsReminder) {
      granted = await ReminderService.instance.requestPermission();
    }
    await ref
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            name: name.isEmpty ? null : name,
            onboarded: true,
            reminderEnabled: granted,
          ),
        );
    if (!mounted) return;
    context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _count - 1;
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: _page > 0
                            ? RoundIconButton(
                                icon: Icons.arrow_back,
                                tooltip: 'Back',
                                size: 20,
                                onTap: () => _goTo(_page - 1),
                              )
                            : null,
                      ),
                      Expanded(
                        child: Semantics(
                          label: 'Step ${_page + 1} of $_count',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < _count; i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: i == _page ? 26 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _page
                                        ? AppColors.accent
                                        : AppColors.lineStrong,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _finish(skipped: true),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      onPageChanged: (p) => setState(() => _page = p),
                      children: [
                        const _IntroPage(
                          art: _Art(icon: Icons.favorite),
                          title: 'One small kind act,\nevery morning.',
                          body:
                              'Each day you get a simple good deed. Most are '
                              'free and take a few minutes.',
                        ),
                        const _IntroPage(
                          art: _Art(icon: Icons.local_fire_department),
                          title: 'Build a streak.\nEarn badges.',
                          body:
                              'Do one a day to grow your streak, unlock badges '
                              'and level up from Seedling to Tree.',
                        ),
                        _NamePage(
                          controller: _name,
                          reminder: _reminder,
                          onReminder: (v) => setState(() => _reminder = v),
                          onSubmit: _finish,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving
                        ? null
                        : isLast
                        ? _finish
                        : () => _goTo(_page + 1),
                    child: Text(isLast ? 'Let’s go' : 'Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Art extends StatelessWidget {
  const _Art({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lime,
      ),
      child: Center(
        child: Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
          ),
          child: Icon(icon, size: 50, color: AppColors.accent),
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.art,
    required this.title,
    required this.body,
  });

  final Widget art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: art),
              const SizedBox(height: 40),
              Text(
                title,
                style: textTheme.displayLarge?.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 12),
              Text(body, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  const _NamePage({
    required this.controller,
    required this.reminder,
    required this.onReminder,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool reminder;
  final ValueChanged<bool> onReminder;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final s = AppSettings(name: controller.text);
              return Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: Text(
                        s.initials,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    PillChip(
                      label: 'Good morning, ${s.displayName}',
                      primary: true,
                      onTap: null,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            'What should we call you?',
            style: textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 10),
          Text(
            'We’ll use it to greet you. It stays on this phone.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: 'Your first name',
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PillChip(
                label: reminder ? 'Morning reminder · 8:00 AM' : 'No reminder',
                icon: reminder
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                primary: reminder,
                onTap: () => onReminder(!reminder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
