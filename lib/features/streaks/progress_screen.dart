import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

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
                          '3 days',
                          style: TextStyle(
                            fontFamily: 'Bricolage Grotesque',
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            height: 1.1,
                          ),
                        ),
                        Text(
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
                  children: const [
                    _DayDot(dayLabel: 'M', completed: true),
                    _DayDot(dayLabel: 'T', completed: true),
                    _DayDot(dayLabel: 'W', completed: true),
                    _DayDot(dayLabel: 'T', completed: false),
                    _DayDot(dayLabel: 'F', completed: false),
                    _DayDot(dayLabel: 'S', completed: false),
                    _DayDot(dayLabel: 'S', completed: false),
                  ],
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
                            const Text(
                              '3 days',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
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
                            const Text(
                              '5',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
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
            childAspectRatio: 0.88,
            children: const [
              _BadgeCard(
                name: 'First Kind Act',
                status: 'Earned',
                isEarned: true,
                icon: Icons.favorite,
              ),
              _BadgeCard(
                name: 'Three-Day',
                status: 'Earned',
                isEarned: true,
                icon: Icons.local_fire_department,
              ),
              _BadgeCard(
                name: 'Seven-Day',
                status: '3 / 7',
                isEarned: false,
                icon: Icons.military_tech_outlined,
              ),
              _BadgeCard(
                name: 'Thirty-Day',
                status: '3 / 30',
                isEarned: false,
                icon: Icons.workspace_premium_outlined,
              ),
              _BadgeCard(
                name: 'Ten Acts',
                status: '5 / 10',
                isEarned: false,
                icon: Icons.stars_outlined,
              ),
              _BadgeCard(
                name: 'Explorer',
                status: '2 / 6',
                isEarned: false,
                icon: Icons.explore_outlined,
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned ? AppColors.accentSoft : AppColors.track,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isEarned ? AppColors.accent : AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isEarned ? AppColors.accentDark : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
