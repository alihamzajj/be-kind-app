// Renders the plant levels and streak flame to build/preview_motion.png.
// Run with: flutter test tool/preview_motion_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:be_kind/core/widgets/motion.dart';
import 'package:be_kind/features/streaks/widgets/growing_plant.dart';

void main() {
  testWidgets('preview', (tester) async {
    tester.view.physicalSize = const Size(900, 220);
    tester.view.devicePixelRatio = 1;
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: key,
          child: Container(
            color: const Color(0xFF3A0B12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                for (var l = 1; l <= 5; l++)
                  const Padding(padding: EdgeInsets.only(right: 16))
                      .copyWithChild(GrowingPlant(level: l)),
                const StreakFlame(size: 90),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('build/preview_motion.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}

extension on Padding {
  Widget copyWithChild(Widget child) => Padding(padding: padding, child: child);
}
