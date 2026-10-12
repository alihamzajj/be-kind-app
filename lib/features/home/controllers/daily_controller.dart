import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:be_kind/core/storage/local_data_service.dart';
import 'package:be_kind/features/kindness_tasks/models/kindness_task.dart';
import 'package:be_kind/features/kindness_tasks/services/daily_task_selector.dart';
import 'package:be_kind/features/task_completion/models/task_completion.dart';
import 'package:be_kind/features/streaks/engine/streak_engine.dart';
import 'package:be_kind/features/achievements/models/badge_models.dart';

final localDataServiceProvider = Provider<LocalDataService>((ref) {
  return LocalDataService();
});

class DailyState {
  const DailyState({
    required this.todayDateStr,
    required this.primaryTask,
    required this.selectedTask,
    required this.alternatives,
    required this.todayCompletion,
    required this.streakResult,
    required this.badges,
    required this.allCompletions,
    required this.isLoading,
  });

  final String todayDateStr;
  final KindnessTask? primaryTask;
  final KindnessTask? selectedTask;
  final List<KindnessTask> alternatives;
  final TaskCompletion? todayCompletion;
  final StreakCalculationResult streakResult;
  final List<UserBadgeProgress> badges;
  final List<TaskCompletion> allCompletions;
  final bool isLoading;

  factory DailyState.initial() {
    return DailyState(
      todayDateStr: StreakEngine.formatLocalDate(DateTime.now()),
      primaryTask: null,
      selectedTask: null,
      alternatives: const [],
      todayCompletion: null,
      streakResult: const StreakCalculationResult(
        currentStreak: 0,
        longestStreak: 0,
        totalCompletedDays: 0,
        lastCompletedDate: null,
      ),
      badges: const [],
      allCompletions: const [],
      isLoading: true,
    );
  }

  DailyState copyWith({
    String? todayDateStr,
    KindnessTask? primaryTask,
    KindnessTask? selectedTask,
    List<KindnessTask>? alternatives,
    TaskCompletion? todayCompletion,
    StreakCalculationResult? streakResult,
    List<UserBadgeProgress>? badges,
    List<TaskCompletion>? allCompletions,
    bool? isLoading,
  }) {
    return DailyState(
      todayDateStr: todayDateStr ?? this.todayDateStr,
      primaryTask: primaryTask ?? this.primaryTask,
      selectedTask: selectedTask ?? this.selectedTask,
      alternatives: alternatives ?? this.alternatives,
      todayCompletion: todayCompletion ?? this.todayCompletion,
      streakResult: streakResult ?? this.streakResult,
      badges: badges ?? this.badges,
      allCompletions: allCompletions ?? this.allCompletions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DailyNotifier extends Notifier<DailyState> {
  @override
  DailyState build() {
    init();
    return DailyState.initial();
  }

  LocalDataService get _dataService => ref.read(localDataServiceProvider);

  Future<void> init() async {
    final now = DateTime.now();
    final todayStr = StreakEngine.formatLocalDate(now);

    final library = await _dataService.loadTaskLibrary();
    final primary = DailyTaskSelector.selectPrimaryTask(
      allTasks: library,
      localDate: todayStr,
    );
    final alternatives = DailyTaskSelector.selectAlternatives(
      allTasks: library,
      primaryTask: primary,
      localDate: todayStr,
    );

    final savedTaskId = await _dataService.getSelectedTaskIdForDate(todayStr);
    KindnessTask activeSelected = primary;
    if (savedTaskId != null) {
      final found = library.firstWhere(
        (t) => t.id == savedTaskId,
        orElse: () => primary,
      );
      activeSelected = found;
    }

    final completions = await _dataService.getCompletions();
    TaskCompletion? todayComp;
    for (final c in completions) {
      if (c.localDate == todayStr) {
        todayComp = c;
        break;
      }
    }

    final completedDates = completions.map((c) => c.localDate).toList();
    final streak = StreakEngine.computeStreak(
      completedDates: completedDates,
      referenceDate: now,
    );

    final badges = await _computeBadges(completions, streak);

    state = DailyState(
      todayDateStr: todayStr,
      primaryTask: primary,
      selectedTask: activeSelected,
      alternatives: alternatives,
      todayCompletion: todayComp,
      streakResult: streak,
      badges: badges,
      allCompletions: completions,
      isLoading: false,
    );
  }

  Future<void> swapTask(KindnessTask task) async {
    await _dataService.setSelectedTaskIdForDate(state.todayDateStr, task.id);
    state = state.copyWith(selectedTask: task);
  }

  Future<TaskCompletion> completeTodayTask({String? note}) async {
    final taskToComplete = state.selectedTask ?? state.primaryTask;
    if (taskToComplete == null) {
      throw StateError('No task available to complete');
    }

    final completion = await _dataService.recordCompletion(
      task: taskToComplete,
      localDate: state.todayDateStr,
      note: note,
    );

    await init();
    return completion;
  }

  Future<List<UserBadgeProgress>> _computeBadges(
    List<TaskCompletion> completions,
    StreakCalculationResult streak,
  ) async {
    final earnedMap = await _dataService.getEarnedBadges();
    final totalActs = completions.length;
    final distinctCategories = completions.map((c) => c.category).toSet().length;

    final List<UserBadgeProgress> list = [];

    for (final def in kAppBadges) {
      int progress = 0;
      bool earned = earnedMap.containsKey(def.id);

      switch (def.id) {
        case 'first_act':
          progress = totalActs;
          if (progress >= 1 && !earned) {
            earned = true;
            await _dataService.recordEarnedBadge(def.id);
          }
          break;
        case 'three_day_streak':
          progress = streak.currentStreak;
          if ((progress >= 3 || streak.longestStreak >= 3) && !earned) {
            earned = true;
            await _dataService.recordEarnedBadge(def.id);
          }
          break;
        case 'seven_day_streak':
          progress = streak.currentStreak;
          if ((progress >= 7 || streak.longestStreak >= 7) && !earned) {
            earned = true;
            await _dataService.recordEarnedBadge(def.id);
          }
          break;
        case 'thirty_day_streak':
          progress = streak.currentStreak;
          if ((progress >= 30 || streak.longestStreak >= 30) && !earned) {
            earned = true;
            await _dataService.recordEarnedBadge(def.id);
          }
          break;
        case 'ten_acts':
          progress = totalActs;
          if (progress >= 10 && !earned) {
            earned = true;
            await _dataService.recordEarnedBadge(def.id);
          }
          break;
        case 'explorer':
          progress = distinctCategories;
          if (progress >= 6 && !earned) {
            earned = true;
            await _dataService.recordEarnedBadge(def.id);
          }
          break;
      }

      list.add(
        UserBadgeProgress(
          definition: def,
          currentProgress: progress,
          isEarned: earned,
          earnedAt: earnedMap[def.id] != null ? DateTime.parse(earnedMap[def.id]!) : null,
        ),
      );
    }

    return list;
  }
}

final dailyNotifierProvider = NotifierProvider<DailyNotifier, DailyState>(DailyNotifier.new);
