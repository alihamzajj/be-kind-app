// Renders the app icon and splash artwork to PNGs under assets/brand/.
// Run with: flutter test tool/generate_brand_assets_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _forest = Color(0xFF163300);
const _lime = Color(0xFF9FE870);

/// The heart from the in-app SVG, in a 24x24 coordinate space.
Path _heart24() => Path()
  ..moveTo(12, 21)
  ..cubicTo(12, 21, 4.5, 16.4, 2.5, 11.8)
  ..cubicTo(1.2, 8.6, 3.3, 5, 6.8, 5)
  ..cubicTo(8.8, 5, 10.4, 6.1, 12, 8)
  ..cubicTo(13.6, 6.1, 15.2, 5, 17.2, 5)
  ..cubicTo(20.7, 5, 22.8, 8.6, 21.5, 11.8)
  ..cubicTo(19.5, 16.4, 12, 21, 12, 21)
  ..close();

/// Heart scaled so it is [width] wide and centred on [center].
Path _heart(Offset center, double width) {
  const minX = 1.2, maxX = 22.8, minY = 5.0, maxY = 21.0;
  final s = width / (maxX - minX);
  final m = Matrix4.identity()
    ..translateByDouble(
      center.dx - (minX + maxX) / 2 * s,
      center.dy - (minY + maxY) / 2 * s,
      0,
      1,
    )
    ..scaleByDouble(s, s, 1, 1);
  return _heart24().transform(m.storage);
}

Future<void> _save(
  String path,
  int size,
  void Function(Canvas c, double s) paint,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  paint(canvas, size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate brand assets', () async {
    // Legacy square icon: forest ground, lime heart.
    await _save('assets/brand/icon.png', 1024, (c, s) {
      c.drawRect(Offset.zero & Size(s, s), Paint()..color = _forest);
      c.drawPath(_heart(Offset(s / 2, s / 2 + s * 0.02), s * 0.56),
          Paint()..color = _lime);
    });

    // Adaptive foreground: heart inside the 66% safe zone, transparent ground.
    await _save('assets/brand/icon_foreground.png', 1024, (c, s) {
      c.drawPath(_heart(Offset(s / 2, s / 2 + s * 0.015), s * 0.40),
          Paint()..color = _lime);
    });

    // Splash mark: forest disc with lime heart (sits on a lime background).
    await _save('assets/brand/splash.png', 1152, (c, s) {
      c.drawCircle(Offset(s / 2, s / 2), s * 0.30, Paint()..color = _forest);
      c.drawPath(_heart(Offset(s / 2, s / 2 + s * 0.012), s * 0.30),
          Paint()..color = _lime);
    });

    // Android 12+ splash icon: shown inside a circle mask by the system.
    await _save('assets/brand/splash_android12.png', 1152, (c, s) {
      c.drawCircle(Offset(s / 2, s / 2), s * 0.32, Paint()..color = _forest);
      c.drawPath(_heart(Offset(s / 2, s / 2 + s * 0.012), s * 0.30),
          Paint()..color = _lime);
    });
  });
}
