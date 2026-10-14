// Renders Kindness Crew screens with a sample collection to build/preview_crew_*.png.
// Run one at a time, e.g.: flutter test tool/preview_crew_test.dart --plain-name crew
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:be_kind/app/app.dart';
import 'package:be_kind/app/router.dart';
import 'package:be_kind/core/settings/app_settings.dart';

// Tests render text as boxes; load real system fonts under the names the
// app asks for so the screenshot is readable.
Future<void> _loadFonts() async {
  Future<void> load(String family, String path) async {
    final loader = FontLoader(family)
      ..addFont(
        Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
      );
    await loader.load();
  }

  const regular = r'C:\Windows\Fonts\segoeui.ttf';
  const bold = r'C:\Windows\Fonts\segoeuib.ttf';
  const semi = r'C:\Windows\Fonts\seguisb.ttf';
  await load('Inter_regular', regular);
  await load('Inter_500', semi);
  for (final w in ['600', '700', '800', '900']) {
    await load('Inter_$w', w == '600' ? semi : bold);
  }
  await load('Roboto', regular);
  final cache = File(Platform.resolvedExecutable).parent.parent.parent;
  await load(
    'MaterialIcons',
    '${cache.path}/material_fonts/materialicons-regular.otf',
  );
}

final _key = GlobalKey();

const _crew = {
  'initialized': true,
  'owned': {
    'momo': {
      'hatchedAt': '2026-10-12T10:00:00.000',
      'shiny': false,
      'bondXp': 9,
    },
    'luna': {
      'hatchedAt': '2026-10-13T10:00:00.000',
      'shiny': false,
      'bondXp': 2,
    },
    'pip': {'hatchedAt': '2026-10-13T10:00:00.000', 'shiny': true, 'bondXp': 0},
    'sunny': {
      'hatchedAt': '2026-10-14T10:00:00.000',
      'shiny': false,
      'bondXp': 18,
    },
  },
  'selectedId': 'momo',
  'eggWarmth': 3,
  'processedActs': 0,
  'pendingReveals': [
    {'id': 'luna', 'isNew': true, 'shiny': false, 'milestone': false},
  ],
};

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUpAll(() async => _loadFonts());
  for (final (name, route, height, wait) in [
    ('crew', '/crew', 1500.0, 3),
    ('hatch', '/crew/hatch', 844.0, 4),
    ('today', '/today', 1300.0, 3),
  ]) {
    testWidgets(name, (tester) async {
      SharedPreferences.setMockInitialValues({
        'flutter.bekind_crew': jsonEncode(_crew),
      });
      tester.view.physicalSize = Size(390, height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialSettingsProvider.overrideWithValue(
              const AppSettings(name: 'Sherry', voiceGreeting: false),
            ),
          ],
          child: RepaintBoundary(key: _key, child: const BeKindApp()),
        ),
      );
      appRouter.go('/today');
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      appRouter.go(route);
      for (var i = 0; i < wait * 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(() async {
        final boundary =
            _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('build/preview_crew_$name.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      await tester.pumpWidget(const SizedBox());
    });
  }
}
