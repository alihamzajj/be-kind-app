import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';

/// True when the user asked the OS to reduce motion.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Pill button that must be pressed and held; lime fills it left to right
/// and [onConfirmed] fires when full. Screen readers get a plain tap.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    required this.label,
    required this.holdingLabel,
    required this.onConfirmed,
    this.duration = const Duration(milliseconds: 1100),
    super.key,
  });

  final String label;
  final String holdingLabel;
  final VoidCallback onConfirmed;
  final Duration duration;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener(_onStatus);
  int _lastTick = 0;

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      HapticFeedback.heavyImpact();
      widget.onConfirmed();
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _c.value = 0;
      });
    }
  }

  void _start() {
    HapticFeedback.selectionClick();
    _lastTick = 0;
    _c.forward();
  }

  void _cancel() {
    if (_c.isCompleted) return;
    _c.animateBack(0, duration: const Duration(milliseconds: 220));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      onTap: widget.onConfirmed,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _start(),
        onTapUp: (_) => _cancel(),
        onTapCancel: _cancel,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            // Light ticks while filling, so the hold feels physical.
            final tick = (_c.value * 4).floor();
            if (_c.status == AnimationStatus.forward && tick > _lastTick) {
              _lastTick = tick;
              HapticFeedback.lightImpact();
            }
            final holding = _c.value > 0 && !_c.isCompleted;
            return AnimatedScale(
              scale: holding ? 0.97 : 1,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: 60,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: AppColors.card,
                  shape: const StadiumBorder(),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _c.value,
                      heightFactor: 1,
                      child: Container(color: AppColors.lime),
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _c.isCompleted
                                ? Icons.check_circle
                                : Icons.check_rounded,
                            size: 22,
                            color: _c.value > 0.45
                                ? AppColors.onLime
                                : AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            holding ? widget.holdingLabel : widget.label,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _c.value > 0.45
                                  ? AppColors.onLime
                                  : AppColors.accent,
                            ),
                          ),
                        ],
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

/// A flame that flickers continuously, with a soft glow behind it.
class StreakFlame extends StatefulWidget {
  const StreakFlame({this.size = 120, this.lit = true, super.key});

  final double size;

  /// Unlit flames (no streak yet) are grey and still.
  final bool lit;

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.lit && !reduceMotion(context)) {
      _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.lit ? 'Streak flame' : 'Streak not started',
      excludeSemantics: true,
      child: SizedBox(
        width: widget.size,
        height: widget.size * 1.15,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              CustomPaint(painter: _FlamePainter(_c.value, widget.lit)),
        ),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter(this.t, this.lit);

  final double t;
  final bool lit;

  Path _flame(Size s, double w, double h, double lean) {
    final cx = s.width / 2;
    final bottom = s.height * 0.96;
    return Path()
      ..moveTo(cx + lean * w * 0.3, bottom - h)
      ..cubicTo(
        cx + w * 0.55 + lean * w * 0.2,
        bottom - h * 0.62,
        cx + w * 0.62,
        bottom - h * 0.2,
        cx,
        bottom,
      )
      ..cubicTo(
        cx - w * 0.62,
        bottom - h * 0.2,
        cx - w * 0.55 + lean * w * 0.2,
        bottom - h * 0.62,
        cx + lean * w * 0.3,
        bottom - h,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final a = t * 2 * math.pi;
    final flick = lit ? math.sin(a) * 0.04 + math.sin(a * 3) * 0.025 : 0.0;
    final lean = lit ? math.sin(a * 2) * 0.12 : 0.0;
    final w = size.width * 0.82;
    final h = size.height * (0.92 + flick);

    if (lit) {
      final glow = Paint()
        ..color = const Color(0xFFFFB27A)
            .withValues(alpha: 0.35 + 0.15 * math.sin(a))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.16);
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.7),
        size.width * 0.38,
        glow,
      );
    }

    canvas.drawPath(
      _flame(size, w, h, lean),
      Paint()..color = lit ? const Color(0xFFE8590C) : AppColors.lineStrong,
    );
    canvas.drawPath(
      _flame(size, w * 0.55, h * (0.58 - flick), -lean * 1.4),
      Paint()..color = lit ? const Color(0xFFFFD166) : AppColors.track,
    );
  }

  @override
  bool shouldRepaint(_FlamePainter old) => old.t != t || old.lit != lit;
}

/// Shows [value]; when it is first shown with [rollFrom] set, the previous
/// digit rolls up and out as the new one rolls in.
class RollingNumber extends StatefulWidget {
  const RollingNumber({
    required this.value,
    required this.style,
    this.rollFrom,
    super.key,
  });

  final int value;
  final int? rollFrom;
  final TextStyle style;

  @override
  State<RollingNumber> createState() => _RollingNumberState();
}

class _RollingNumberState extends State<RollingNumber> {
  late int _shown = widget.rollFrom ?? widget.value;

  @override
  void initState() {
    super.initState();
    if (_shown != widget.value) {
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _shown = widget.value);
      });
    }
  }

  @override
  void didUpdateWidget(RollingNumber old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _shown = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: reduceMotion(context) ? 0 : 520),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) {
        final incoming = child.key == ValueKey(_shown);
        final offset = Tween<Offset>(
          begin: incoming ? const Offset(0, 0.9) : const Offset(0, -0.9),
          end: Offset.zero,
        ).animate(anim);
        return ClipRect(
          child: SlideTransition(
            position: offset,
            child: FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      child: Text('$_shown', key: ValueKey(_shown), style: widget.style),
    );
  }
}

/// Counts up from zero to [value] the first time it is shown.
class CountUpText extends StatelessWidget {
  const CountUpText({
    required this.value,
    required this.style,
    this.suffix = '',
    this.delay = Duration.zero,
    super.key,
  });

  final int value;
  final String suffix;
  final TextStyle style;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return Text('$value$suffix', style: style);
    final total = const Duration(milliseconds: 900) + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (context, v, _) => Text('${v.round()}$suffix', style: style),
    );
  }
}
