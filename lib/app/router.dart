import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/home/today_screen.dart';
import '../features/task_completion/task_completed_screen.dart';
import '../features/streaks/progress_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/profile/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/today/done',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final title = extra?['title'] as String?;
        final streak = extra?['streak'] as int? ?? 4;
        return TaskCompletedScreen(taskTitle: title, streakCount: streak);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const TodayScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/friends',
              builder: (context, state) => const FriendsPlaceholderScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePlaceholderScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
