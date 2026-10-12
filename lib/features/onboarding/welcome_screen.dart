import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentSoft.withValues(alpha: 0.35),
                        ),
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentSoft,
                        ),
                      ),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                        ),
                        child: const Icon(
                          Icons.favorite_outline,
                          size: 48,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'One kind act,\nevery day.',
                style: textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Get a small, doable good deed each morning. Most cost nothing and take minutes.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.go('/today'),
                child: const Text('Start as a guest'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account sign-in coming soon in Phase 3'),
                    ),
                  );
                },
                child: const Text('Sign in or create account'),
              ),
              const SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text.rich(
                    TextSpan(
                      text: 'As a guest, your progress stays on this device. Create an account anytime to back it up. ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Privacy',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
