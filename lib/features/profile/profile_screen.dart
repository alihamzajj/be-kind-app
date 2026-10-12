import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSoft,
              ),
              child: const Icon(Icons.person_outline, color: AppColors.accent, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Guest Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your progress is stored locally on this device.\nAccount management and sync will be available in Phase 3.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
