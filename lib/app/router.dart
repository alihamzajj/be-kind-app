import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profile/reminder_settings_screen.dart';
import '../features/home/today_screen.dart';
import '../features/task_completion/task_completed_screen.dart';
import '../features/streaks/progress_screen.dart';
import '../features/history/history_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/kindness_tasks/models/kindness_task.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Where the app opens; set in `main` once settings are loaded.
String appStartLocation = '/welcome';

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: appStartLocation,
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/reminders',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReminderSettingsScreen(),
    ),
    GoRoute(
      path: '/auth',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/history',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/today/done',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final task = extra?['task'] as KindnessTask?;
        final predictedStreak = extra?['predictedStreak'] as int? ?? 1;
        final existingNote = extra?['existingNote'] as String?;
        return TaskCompletedScreen(
          task: task,
          predictedStreak: predictedStreak,
          existingNote: existingNote,
        );
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
              builder: (context, state) => const FriendsScreen(),
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
