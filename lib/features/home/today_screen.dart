import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import 'widgets/alternatives_sheet.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  String _currentTitle = 'Send an encouraging note to someone you appreciate';
  String _currentWhy = 'A few sincere words can transform someone’s tough day and strengthens relationships deeply.';
  String _currentCategory = 'Gratitude';
  String _currentDuration = '5 min';
  final String _currentDifficulty = 'Easy';
  bool _completedToday = false;

  void _openAlternatives() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AlternativesSheet(
          onSelect: (item) {
            Navigator.pop(context);
            setState(() {
              _currentTitle = item.title;
              _currentCategory = item.category;
              _currentDuration = item.duration;
              _currentWhy = 'A meaningful act of kindness that lifts spirits and helps our community.';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Swapped to: ${item.title}')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;

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
                    'Monday, Oct 12',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Good morning, Friend',
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department, color: AppColors.streak, size: 20),
                    SizedBox(width: 6),
                    Text(
                      '3',
                      style: TextStyle(
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
                    Text(
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
                        _currentCategory,
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
                  _currentTitle,
                  style: isDesktop
                      ? textTheme.headlineSmall?.copyWith(fontSize: 32)
                      : textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  _currentWhy,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(icon: Icons.schedule, label: _currentDuration),
                    _MetaChip(icon: Icons.signal_cellular_alt, label: _currentDifficulty),
                    const _MetaChip(icon: Icons.savings_outlined, label: 'No money needed'),
                  ],
                ),
                const SizedBox(height: 24),
                if (!_completedToday)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            context.push(
                              '/today/done',
                              extra: {
                                'title': _currentTitle,
                                'streak': 4,
                              },
                            ).then((res) {
                              if (res == true) {
                                setState(() => _completedToday = true);
                              }
                            });
                          },
                          child: const Text('I did it'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _openAlternatives,
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
                              extra: {'title': _currentTitle, 'streak': 4},
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
          Container(
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
                    const Text(
                      'Next badge: 7-Day Streak',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '3 / 7 days',
                      style: TextStyle(
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
                    value: 3 / 7,
                    minHeight: 10,
                    backgroundColor: AppColors.track,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '4 more consecutive days to earn this badge',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Other ideas for today
          Text(
            'Other ideas for today',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _QuickIdeaRow(
            title: 'Water a wilted plant in your home or hallway',
            subtitle: 'Environment · 2 min',
            icon: Icons.park_outlined,
            onTap: _openAlternatives,
          ),
          const SizedBox(height: 10),
          _QuickIdeaRow(
            title: 'Leave a genuine review for a local mom-and-pop shop',
            subtitle: 'Community · 4 min',
            icon: Icons.storefront_outlined,
            onTap: _openAlternatives,
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
            style: TextStyle(
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
                    style: TextStyle(
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
