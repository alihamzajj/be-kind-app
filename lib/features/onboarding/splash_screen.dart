import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/motion.dart';

/// Animated hand-off from the native lime launch screen: the heart beats,
/// rings ripple out and the name rises in, then the app moves on.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      )..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          context.go(appStartLocation);
        }
      });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.isAnimating || _c.isCompleted) return;
    if (reduceMotion(context)) {
      // Skip the show, keep a brief beat so the hand-off isn't jarring.
      _c.duration = const Duration(milliseconds: 400);
    }
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lime,
      body: Semantics(
        label: 'Be Kind. One kind act, every day.',
        excludeSemantics: true,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final ms = t * 2000;

            // Two heartbeats: quick double pulse, like the mockup.
            double beat(double start) {
              final x = (ms - start) / 600;
              if (x < 0 || x > 1) return 0;
              return math.sin(x * math.pi) * (x < 0.5 ? 0.14 : 0.07);
            }

            final scale = 1 + beat(250) + beat(1050);

            // Ripples expand and fade from the icon.
            Widget ripple(double startMs) {
              final x = ((ms - startMs) / 1200).clamp(0.0, 1.0);
              if (ms < startMs) return const SizedBox.shrink();
              return Opacity(
                opacity: (1 - x) * 0.55,
                child: Transform.scale(
                  scale: 0.8 + x * 1.6,
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.onLime, width: 3),
                    ),
                  ),
                ),
              );
            }

            double rise(double startMs) => Curves.easeOutCubic.transform(
              ((ms - startMs) / 500).clamp(0.0, 1.0),
            );
            final nameIn = rise(500);
            final tagIn = rise(700);

            // Fade the whole splash out at the very end.
            final out = ((ms - 1750) / 250).clamp(0.0, 1.0);

            return Opacity(
              opacity: 1 - out,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ripple(250),
                          ripple(850),
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 124,
                              height: 124,
                              decoration: BoxDecoration(
                                color: AppColors.onLime,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.onLime.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 44,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite,
                                size: 62,
                                color: AppColors.lime,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: nameIn,
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - nameIn)),
                        child: const Text(
                          'Be Kind',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.6,
                            color: AppColors.onLime,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: tagIn * 0.85,
                      child: Transform.translate(
                        offset: Offset(0, 14 * (1 - tagIn)),
                        child: const Text(
                          'One kind act, every day.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onLime,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
