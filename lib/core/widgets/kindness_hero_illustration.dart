import 'package:flutter/material.dart';
import 'package:be_kind/app/theme/app_colors.dart';

class KindnessHeroIllustration extends StatelessWidget {
  const KindnessHeroIllustration({
    this.height = 100,
    super.key,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _KindnessHeroPainter(),
      ),
    );
  }
}

class _KindnessHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft warm background gradient glow
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.6, -0.2),
        radius: 0.9,
        colors: [
          AppColors.accentSoft.withValues(alpha: 0.45),
          AppColors.streakSoft.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Warm sun aura in top-right
    final sunCenter = Offset(w * 0.82, h * 0.28);
    final sunAuraPaint = Paint()
      ..color = AppColors.streakSoft.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 28, sunAuraPaint);

    final sunCorePaint = Paint()
      ..color = AppColors.streak.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 14, sunCorePaint);

    // Flowing gentle hills/waves (representing growth & ground)
    final hillPaint1 = Paint()
      ..color = AppColors.accentSoft.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.25, h * 0.55, w * 0.55, h * 0.72)
      ..quadraticBezierTo(w * 0.8, h * 0.85, w, h * 0.65)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path1, hillPaint1);

    final hillPaint2 = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, h * 0.9)
      ..quadraticBezierTo(w * 0.35, h * 0.75, w * 0.7, h * 0.88)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path2, hillPaint2);

    // Floating heart sprout on the left
    final sproutCenter = Offset(w * 0.14, h * 0.48);
    final sproutStemPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.35)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(sproutCenter.dx, h * 0.75)
      ..quadraticBezierTo(sproutCenter.dx - 8, h * 0.6, sproutCenter.dx, sproutCenter.dy);
    canvas.drawPath(stemPath, sproutStemPaint);

    // Leaves
    final leafPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final leaf1 = Path()
      ..moveTo(sproutCenter.dx - 4, h * 0.62)
      ..quadraticBezierTo(sproutCenter.dx - 18, h * 0.58, sproutCenter.dx - 16, h * 0.66)
      ..quadraticBezierTo(sproutCenter.dx - 10, h * 0.68, sproutCenter.dx - 4, h * 0.62);
    canvas.drawPath(leaf1, leafPaint);

    final leaf2 = Path()
      ..moveTo(sproutCenter.dx + 2, h * 0.58)
      ..quadraticBezierTo(sproutCenter.dx + 16, h * 0.54, sproutCenter.dx + 14, h * 0.62)
      ..quadraticBezierTo(sproutCenter.dx + 8, h * 0.64, sproutCenter.dx + 2, h * 0.58);
    canvas.drawPath(leaf2, leafPaint);

    // Heart blossom
    final heartPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    _drawHeart(canvas, sproutCenter, 10, heartPaint);

    // Little sparkling dots
    final dotPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.45, h * 0.32), 2.5, dotPaint);
    canvas.drawCircle(Offset(w * 0.58, h * 0.24), 3.5, dotPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.46), 2.0, dotPaint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.6);
    path.cubicTo(
      center.dx - size * 1.2,
      center.dy - size * 0.4,
      center.dx - size * 0.6,
      center.dy - size * 1.1,
      center.dx,
      center.dy - size * 0.4,
    );
    path.cubicTo(
      center.dx + size * 0.6,
      center.dy - size * 1.1,
      center.dx + size * 1.2,
      center.dy - size * 0.4,
      center.dx,
      center.dy + size * 0.6,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
