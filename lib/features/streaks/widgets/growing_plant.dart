import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/widgets/motion.dart';

/// A potted plant that grows to match the user's level (1 Seedling …
/// 5 Forest). It grows in when first shown, then sways gently.
class GrowingPlant extends StatefulWidget {
  const GrowingPlant({
    required this.level,
    this.width = 120,
    this.height = 140,
    super.key,
  });

  final int level;
  final double width;
  final double height;

  @override
  State<GrowingPlant> createState() => _GrowingPlantState();
}

class _GrowingPlantState extends State<GrowingPlant>
    with TickerProviderStateMixin {
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final AnimationController _sway = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _grow.value = 1;
      _sway.stop();
    } else {
      if (_grow.value == 0) _grow.forward();
      _sway.repeat();
    }
  }

  @override
  void didUpdateWidget(GrowingPlant old) {
    super.didUpdateWidget(old);
    if (old.level != widget.level && !reduceMotion(context)) {
      _grow.forward(from: 0.35);
    }
  }

  @override
  void dispose() {
    _grow.dispose();
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const names = ['Seedling', 'Sprout', 'Bloom', 'Tree', 'Forest'];
    return Semantics(
      label:
          'Plant at level ${widget.level}, '
          '${names[(widget.level - 1).clamp(0, 4)]}',
      excludeSemantics: true,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: Listenable.merge([_grow, _sway]),
          builder: (context, _) => CustomPaint(
            painter: _PlantPainter(
              level: widget.level.clamp(1, 5),
              g: Curves.easeOutCubic.transform(_grow.value),
              sway: math.sin(_sway.value * 2 * math.pi),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantPainter extends CustomPainter {
  _PlantPainter({required this.level, required this.g, required this.sway});

  final int level;
  final double g;
  final double sway;

  static const _stem = Color(0xFF6BAE3A);
  static const _leafDark = Color(0xFF4E8A25);
  static const _leafLight = Color(0xFF9FE870);
  static const _petalA = Color(0xFFFFC2D1);
  static const _petalB = Color(0xFFFF8A5B);
  static const _core = Color(0xFFFFD166);
  static const _pot = Color(0xFFB4532A);
  static const _potRim = Color(0xFFD06A3A);

  /// 0..1 progress of a sub-phase that runs between [a] and [b] of growth.
  double _phase(double a, double b) => ((g - a) / (b - a)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final potTop = h * 0.78;
    final base = Offset(w / 2, potTop);

    // Pot
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.3, potTop)
        ..lineTo(w * 0.7, potTop)
        ..lineTo(w * 0.64, h)
        ..lineTo(w * 0.36, h)
        ..close(),
      Paint()..color = _pot,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, potTop - h * 0.04, w * 0.48, h * 0.07),
        Radius.circular(h * 0.02),
      ),
      Paint()..color = _potRim,
    );

    // Sway pivots around the soil line.
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(sway * 0.04);
    canvas.translate(-base.dx, -base.dy);

    final fullStem = [0.22, 0.38, 0.5, 0.42, 0.42][level - 1] * h;
    final stemLen = fullStem * _phase(0, 0.5);
    final top = Offset(base.dx + sway * 2, base.dy - stemLen);

    if (level >= 4) {
      _tree(canvas, base, top, w);
      if (level == 5) {
        // Two smaller trees either side make a little forest.
        final p = _phase(0.55, 1);
        _miniTree(canvas, Offset(w * 0.16, potTop), h * 0.3 * p);
        _miniTree(canvas, Offset(w * 0.84, potTop), h * 0.26 * p);
      }
      canvas.restore();
      return;
    }

    // Stem
    final stemPaint = Paint()
      ..color = _stem
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    if (stemLen > 0) {
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(
            base.dx - w * 0.05,
            base.dy - stemLen * 0.5,
            top.dx,
            top.dy,
          ),
        stemPaint,
      );
    }

    // Leaves along the stem
    final leafCount = [2, 4, 4][level - 1];
    for (var i = 0; i < leafCount; i++) {
      final p = _phase(0.25 + i * 0.1, 0.55 + i * 0.1);
      if (p == 0) continue;
      final along = level == 1 ? 1.0 : 0.3 + 0.55 * (i ~/ 2) / 1.0;
      final at = Offset.lerp(base, top, along.clamp(0.0, 1.0))!;
      final left = i.isEven;
      _leaf(
        canvas,
        at,
        w * (level == 1 ? 0.2 : 0.24) * p,
        left ? -0.6 : 0.6,
        left ? _leafDark : _leafLight,
      );
    }

    // Flower on top
    if (level == 3) {
      final p = Curves.elasticOut.transform(_phase(0.6, 1));
      final r = w * 0.09 * p;
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3 + sway * 0.1;
        canvas.drawCircle(
          top + Offset(math.cos(a), math.sin(a)) * r * 1.3,
          r,
          Paint()..color = i.isEven ? _petalA : _petalB,
        );
      }
      canvas.drawCircle(top, r * 0.85, Paint()..color = _core);
    }
    canvas.restore();
  }

  void _leaf(Canvas c, Offset at, double len, double angle, Color color) {
    c.save();
    c.translate(at.dx, at.dy);
    c.rotate(angle);
    c.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.5, -len * 0.55, len, 0)
        ..quadraticBezierTo(len * 0.5, len * 0.35, 0, 0)
        ..close(),
      Paint()..color = color,
    );
    c.restore();
  }

  void _tree(Canvas c, Offset base, Offset top, double w) {
    c.drawLine(
      base,
      top,
      Paint()
        ..color = const Color(0xFF7A4A24)
        ..strokeWidth = w * 0.07
        ..strokeCap = StrokeCap.round,
    );
    final p = Curves.easeOutBack.transform(_phase(0.35, 0.9));
    final r = w * 0.17 * p;
    final crown = [
      (const Offset(0, -0.9), _leafDark),
      (const Offset(-0.9, -0.2), _leafDark),
      (const Offset(0.9, -0.2), _leafDark),
      (const Offset(-0.45, 0.35), _stem),
      (const Offset(0.45, 0.35), _stem),
      (Offset.zero, _leafLight),
    ];
    for (final (o, color) in crown) {
      c.drawCircle(top + o * r, r, Paint()..color = color);
    }
  }

  void _miniTree(Canvas c, Offset base, double height) {
    if (height <= 0) return;
    final top = base - Offset(0, height);
    c.drawLine(
      base,
      top,
      Paint()
        ..color = const Color(0xFF7A4A24)
        ..strokeWidth = height * 0.12
        ..strokeCap = StrokeCap.round,
    );
    c.drawCircle(top, height * 0.38, Paint()..color = _leafDark);
    c.drawCircle(
      top + Offset(height * 0.12, height * 0.08),
      height * 0.24,
      Paint()..color = _stem,
    );
  }

  @override
  bool shouldRepaint(_PlantPainter old) =>
      old.g != g || old.sway != sway || old.level != level;
}
