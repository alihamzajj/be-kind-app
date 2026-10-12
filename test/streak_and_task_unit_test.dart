import 'package:flutter_test/flutter_test.dart';
import 'package:be_kind/features/streaks/engine/streak_engine.dart';
import 'package:be_kind/features/kindness_tasks/models/kindness_task.dart';
import 'package:be_kind/features/kindness_tasks/services/daily_task_selector.dart';

void main() {
  group('DailyTaskSelector', () {
    final mockTasks = [
      const KindnessTask(
        id: 't1',
        title: 'Task 1',
        description: 'Desc 1',
        category: 'Gratitude',
        estimatedMinutes: 5,
        difficulty: 'Easy',
        moneyRequired: false,
        safetyNotes: '',
        active: true,
      ),
      const KindnessTask(
        id: 't2',
        title: 'Task 2',
        description: 'Desc 2',
        category: 'Community',
        estimatedMinutes: 5,
        difficulty: 'Easy',
        moneyRequired: false,
        safetyNotes: '',
        active: true,
      ),
      const KindnessTask(
        id: 't3',
        title: 'Task 3',
        description: 'Desc 3',
        category: 'Environment',
        estimatedMinutes: 5,
        difficulty: 'Easy',
        moneyRequired: false,
        safetyNotes: '',
        active: true,
      ),
      const KindnessTask(
        id: 't4',
        title: 'Task 4',
        description: 'Desc 4',
        category: 'Self-kindness',
        estimatedMinutes: 5,
        difficulty: 'Easy',
        moneyRequired: false,
        safetyNotes: '',
        active: true,
      ),
      const KindnessTask(
        id: 't5',
        title: 'Task 5',
        description: 'Desc 5',
        category: 'Helping someone',
        estimatedMinutes: 5,
        difficulty: 'Easy',
        moneyRequired: false,
        safetyNotes: '',
        active: true,
      ),
    ];

    test('is deterministic for the same local date', () {
      final taskDayA1 = DailyTaskSelector.selectPrimaryTask(allTasks: mockTasks, localDate: '2026-10-12');
      final taskDayA2 = DailyTaskSelector.selectPrimaryTask(allTasks: mockTasks, localDate: '2026-10-12');
      expect(taskDayA1.id, equals(taskDayA2.id));
    });

    test('selects alternatives excluding primary task', () {
      final primary = DailyTaskSelector.selectPrimaryTask(allTasks: mockTasks, localDate: '2026-10-12');
      final alts = DailyTaskSelector.selectAlternatives(
        allTasks: mockTasks,
        primaryTask: primary,
        localDate: '2026-10-12',
        count: 3,
      );

      expect(alts.length, lessThanOrEqualTo(3));
      expect(alts.any((t) => t.id == primary.id), isFalse);
    });
  });

  group('StreakEngine', () {
    test('computes streak of 0 when no completions exist', () {
      final res = StreakEngine.computeStreak(
        completedDates: [],
        referenceDate: DateTime(2026, 10, 12),
      );
      expect(res.currentStreak, 0);
      expect(res.longestStreak, 0);
      expect(res.totalCompletedDays, 0);
    });

    test('starts streak of 1 on first completion today', () {
      final res = StreakEngine.computeStreak(
        completedDates: ['2026-10-12'],
        referenceDate: DateTime(2026, 10, 12),
      );
      expect(res.currentStreak, 1);
      expect(res.longestStreak, 1);
      expect(res.totalCompletedDays, 1);
    });

    test('increments streak on consecutive days', () {
      final res = StreakEngine.computeStreak(
        completedDates: ['2026-10-10', '2026-10-11', '2026-10-12'],
        referenceDate: DateTime(2026, 10, 12),
      );
      expect(res.currentStreak, 3);
      expect(res.longestStreak, 3);
      expect(res.totalCompletedDays, 3);
    });

    test('does not give duplicate streak credits for multiple completions on same day', () {
      final res = StreakEngine.computeStreak(
        completedDates: ['2026-10-11', '2026-10-12', '2026-10-12', '2026-10-12'],
        referenceDate: DateTime(2026, 10, 12),
      );
      expect(res.currentStreak, 2);
      expect(res.longestStreak, 2);
      expect(res.totalCompletedDays, 2);
    });

    test('streak is preserved when yesterday was completed and today is still in progress', () {
      final res = StreakEngine.computeStreak(
        completedDates: ['2026-10-10', '2026-10-11'],
        referenceDate: DateTime(2026, 10, 12), // Today is the 12th, completed through 11th
      );
      expect(res.currentStreak, 2);
      expect(res.longestStreak, 2);
    });

    test('resets streak to 0 if a full calendar day is missed', () {
      // Completed on Oct 10, but reference date is Oct 12 (Oct 11 was missed completely)
      final res = StreakEngine.computeStreak(
        completedDates: ['2026-10-09', '2026-10-10'],
        referenceDate: DateTime(2026, 10, 12),
      );
      expect(res.currentStreak, 0);
      expect(res.longestStreak, 2);
      expect(res.totalCompletedDays, 2);
    });

    test('restarts streak at 1 after a missed day when a new completion occurs', () {
      // Completed Oct 9, 10, missed 11, completed Oct 12
      final res = StreakEngine.computeStreak(
        completedDates: ['2026-10-09', '2026-10-10', '2026-10-12'],
        referenceDate: DateTime(2026, 10, 12),
      );
      expect(res.currentStreak, 1);
      expect(res.longestStreak, 2);
      expect(res.totalCompletedDays, 3);
    });
  });
}
