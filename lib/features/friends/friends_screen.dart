import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class FriendsPlaceholderScreen extends StatelessWidget {
  const FriendsPlaceholderScreen({super.key});

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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSoft,
              ),
              child: const Icon(Icons.people_outline, color: AppColors.accent, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Kindness with friends',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Friend connections and encouragement feeds will be available in Phase 5.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
