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
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 48).clamp(0.0, double.infinity),
                  maxWidth: 520,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        child: Center(child: FittedBox(child: _Hero())),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'One kind act,\nevery day.',
                        style: textTheme.displayLarge?.copyWith(fontSize: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Get a small, doable good deed each morning. '
                        'Most cost nothing and take minutes.',
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: () => context.go('/onboarding'),
                        child: const Text('Start as a guest'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => context.push('/auth'),
                        child: const Text('Sign in or create account'),
                      ),
                      const SizedBox(height: 18),
                      Text.rich(
                        TextSpan(
                          text:
                              'As a guest, your progress stays on this device. '
                              'Create an account anytime to back it up. ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: 'Privacy',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 210,
            height: 210,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lime,
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            child: Icon(
              Icons.favorite,
              size: 52,
              color: AppColors.accent,
            ),
          ),
          const Positioned(
            left: 0,
            top: 34,
            child: _FloatingPill(
              icon: Icons.local_fire_department,
              label: '7 day streak',
            ),
          ),
          const Positioned(
            right: 0,
            bottom: 30,
            child: _FloatingPill(icon: Icons.schedule, label: '2 min'),
          ),
        ],
      ),
    );
  }
}

class _FloatingPill extends StatelessWidget {
  const _FloatingPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.streak),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
