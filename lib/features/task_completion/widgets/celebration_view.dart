import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../achievements/models/badge_models.dart';

/// Full-screen "you did it" moment: confetti burst, popping check mark,
/// streak pill and any badge earned by this completion.
class CelebrationView extends StatefulWidget {
  const CelebrationView({
    required this.streak,
    required this.taskTitle,
    required this.onContinue,
    this.newBadge,
    this.onShare,
    super.key,
  });

  final int streak;
  final String taskTitle;
  final BadgeDefinition? newBadge;
  final VoidCallback onContinue;
  final VoidCallback? onShare;

  @override
  State<CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<CelebrationView>
    with TickerProviderStateMixin {
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final List<_Piece> _pieces = _Piece.burst(70);

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    if (widget.newBadge != null) {
      Future<void>.delayed(
        const Duration(milliseconds: 450),
        HapticFeedback.mediumImpact,
      );
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scale = CurvedAnimation(parent: _pop, curve: Curves.elasticOut);
    final fade = CurvedAnimation(
      parent: _pop,
      curve: const Interval(0.3, 1, curve: Curves.easeOut),
    );
    final badge = widget.newBadge;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: scale,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.lime,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentSoft,
                                  spreadRadius: 14,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 66,
                              color: AppColors.onLime,
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        FadeTransition(
                          opacity: fade,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.streakSoft,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      size: 16,
                                      color: AppColors.streak,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${widget.streak} day streak',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.streak,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Day ${widget.streak}!\nNicely done.',
                                textAlign: TextAlign.center,
                                style: textTheme.displayLarge?.copyWith(
                                  fontSize: 38,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.taskTitle,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (badge != null)
                FadeTransition(
                  opacity: fade,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.promo,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.lime,
                          ),
                          child: Icon(
                            badge.icon,
                            color: AppColors.onLime,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NEW BADGE UNLOCKED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: AppColors.lime,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                badge.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                badge.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFE6D3D6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (widget.onShare != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onShare,
                        child: const Text('Share'),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: widget.onContinue,
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (context, _) => CustomPaint(
                painter: _ConfettiPainter(_pieces, _confetti.value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Piece {
  _Piece(this.angle, this.speed, this.color, this.spin, this.round, this.size);

  final double angle;
  final double speed;
  final Color color;
  final double spin;
  final bool round;
  final double size;

  static List<_Piece> burst(int n) {
    final rnd = math.Random();
    final colors = [
      AppColors.lime,
      Color(0xFFFF8A5B),
      Color(0xFFFFC2D1),
      Color(0xFFB794F6),
      Color(0xFFFFD166),
      AppColors.accent,
    ];
    return List.generate(n, (i) {
      // Mostly upward fan so pieces rise then fall.
      final angle = -math.pi / 2 + (rnd.nextDouble() - 0.5) * math.pi * 1.1;
      return _Piece(
        angle,
        0.55 + rnd.nextDouble() * 0.6,
        colors[i % colors.length],
        (rnd.nextDouble() - 0.5) * 14,
        rnd.nextInt(3) == 0,
        6 + rnd.nextDouble() * 6,
      );
    });
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    final origin = Offset(size.width / 2, size.height * 0.3);
    final reach = size.height * 0.75;
    final opacity = (1 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);
    for (final p in pieces) {
      final dist = reach * p.speed * Curves.easeOut.transform(t);
      final gravity = size.height * 0.9 * t * t;
      final pos =
          origin +
          Offset(math.cos(p.angle) * dist, math.sin(p.angle) * dist + gravity);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 1.6,
              height: p.size * 0.7,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
