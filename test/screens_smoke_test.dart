import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:be_kind/app/app.dart';
import 'package:be_kind/app/router.dart';
import 'package:be_kind/core/settings/app_settings.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  const sizes = [
    Size(320, 640),
    Size(390, 844),
    Size(700, 1000),
    Size(1280, 800),
  ];
  const routes = [
    '/welcome',
    '/onboarding',
    '/today',
    '/progress',
    '/friends',
    '/profile',
    '/history',
    '/reminders',
    '/today/done',
    '/crew',
    '/crew/hatch',
  ];

  for (final dark in [false, true]) {
    for (final size in sizes) {
      for (final route in routes) {
        testWidgets(
          'smoke ${dark ? 'dark' : 'light'} $route @ ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
            SharedPreferences.setMockInitialValues({});
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(() => tester.view.resetPhysicalSize());

            final errors = <String>[];
            final old = FlutterError.onError;
            FlutterError.onError = (d) {
              final s = d.toString();
              if (s.contains('google_fonts') || s.contains('GoogleFonts')) {
                return;
              }
              errors.add(s.split('\n').take(12).join('\n'));
            };

            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  initialSettingsProvider.overrideWithValue(
                    AppSettings(
                      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),
                ],
                child: const BeKindApp(),
              ),
            );
            appRouter.go(route);
            for (var i = 0; i < 20; i++) {
              await tester.pump(const Duration(milliseconds: 100));
            }
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 300)),
            );
            for (var i = 0; i < 20; i++) {
              await tester.pump(const Duration(milliseconds: 100));
            }
            FlutterError.onError = old;
            final ex = tester.takeException();
            if (ex != null &&
                !ex.toString().contains('GoogleFonts') &&
                !ex.toString().contains('google_fonts')) {
              errors.add('EXCEPTION: $ex');
            }
            await tester.pumpWidget(const SizedBox());
            await tester.pump(const Duration(seconds: 5));
            expect(errors, isEmpty, reason: errors.join('\n-----\n'));
          },
        );
      }
    }
  }
}
