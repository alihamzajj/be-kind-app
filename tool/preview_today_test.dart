// Renders the Today screen (light + dark, phone size) to build/preview_today_*.png.
// Run one theme at a time (state leaks between them), e.g.:
//   flutter test tool/preview_today_test.dart --plain-name "preview today dark"
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

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUpAll(() async => _loadFonts());
  for (final dark in [false, true]) {
    testWidgets('preview today ${dark ? 'dark' : 'light'}', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialSettingsProvider.overrideWithValue(
              AppSettings(
                name: 'Sherry',
                themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              ),
            ),
          ],
          child: RepaintBoundary(key: _key, child: const BeKindApp()),
        ),
      );
      appRouter.go('/today');
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.runAsync(() async {
        final boundary =
            _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('build/preview_today_${dark ? 'dark' : 'light'}.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      await tester.pumpWidget(const SizedBox());
    });
  }
}
