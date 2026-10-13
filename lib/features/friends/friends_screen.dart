import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/ui.dart';
import '../profile/profile_screen.dart';

class FriendsPlaceholderScreen extends StatelessWidget {
  const FriendsPlaceholderScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Friends are coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final hPad = pagePadding(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Friends',
            trailing: RoundIconButton(
              icon: Icons.person_add_alt,
              tooltip: 'Invite',
              onTap: () => _comingSoon(context),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PillChip(
                label: 'Invite',
                primary: true,
                onTap: () => _comingSoon(context),
              ),
              PillChip(
                label: 'Find friends',
                onTap: () => _comingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const MotivationalBanner(),
          const SizedBox(height: 28),
          const SectionHeader(title: 'What you’ll get'),
          const SizedBox(height: 4),
          const ActivityRow(
            icon: Icons.people_outline,
            title: 'Shared streaks',
            subtitle: 'Keep a streak going together',
          ),
          const ActivityRow(
            icon: Icons.celebration_outlined,
            title: 'Cheers',
            subtitle: 'Send encouragement when friends finish a kind act',
          ),
          const ActivityRow(
            icon: Icons.lock_outline,
            title: 'Private by default',
            subtitle: 'Friends see the task, never your notes',
          ),
          const SizedBox(height: 8),
          Text(
            'Friend connections arrive in a future update.',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
