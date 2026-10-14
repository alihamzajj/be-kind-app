import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:be_kind/app/app.dart';
import 'package:be_kind/app/app_shell.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Welcome screen renders both Start as a guest and Sign in buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BeKindApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('One kind act,\nevery day.'), findsOneWidget);
    expect(find.text('Start as a guest'), findsOneWidget);
    expect(find.text('Sign in or create account'), findsOneWidget);
  });

  testWidgets('AppShell shows glass tab buttons at 390px mobile width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testRouter = GoRouter(
      initialLocation: '/today',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/today',
                  builder: (context, state) => const Scaffold(body: Text('Today Body')),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsWidgets);
    for (final label in ['Today', 'Progress', 'Friends', 'Profile']) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('AppShell shows desktop sidebar at 1280px width', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testRouter = GoRouter(
      initialLocation: '/today',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/today',
                  builder: (context, state) => const Scaffold(body: Text('Today Desktop')),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Be Kind'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
  });
}
