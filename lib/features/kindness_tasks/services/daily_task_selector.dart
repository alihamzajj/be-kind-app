import '../models/kindness_task.dart';

class DailyTaskSelector {
  /// Deterministically derives a positive integer hash from a date string (YYYY-MM-DD)
  static int dateHash(String dateStr) {
    int hash = 0;
    for (int i = 0; i < dateStr.length; i++) {
      hash = (31 * hash + dateStr.codeUnitAt(i)) & 0x7fffffff;
    }
    return hash;
  }

  /// Selects the primary task for a given local date deterministically.
  /// The same local date will ALWAYS yield the exact same primary task.
  static KindnessTask selectPrimaryTask({
    required List<KindnessTask> allTasks,
    required String localDate,
  }) {
    if (allTasks.isEmpty) {
      throw ArgumentError('Task library cannot be empty');
    }
    final activeTasks = allTasks.where((t) => t.active).toList();
    if (activeTasks.isEmpty) {
      return allTasks.first;
    }
    final index = dateHash(localDate) % activeTasks.length;
    return activeTasks[index];
  }

  /// Selects 3 to 5 eligible alternative tasks from different categories if possible
  static List<KindnessTask> selectAlternatives({
    required List<KindnessTask> allTasks,
    required KindnessTask primaryTask,
    required String localDate,
    int count = 4,
  }) {
    final activeTasks = allTasks
        .where((t) => t.active && t.id != primaryTask.id)
        .toList();

    if (activeTasks.length <= count) {
      return activeTasks;
    }

    // Pseudo-random offset based on local date
    final offset = (dateHash(localDate) ~/ 7) % activeTasks.length;
    final List<KindnessTask> results = [];
    final Set<String> usedCategories = {primaryTask.category};

    // First pass: try to pick diverse categories
    for (int i = 0; i < activeTasks.length && results.length < count; i++) {
      final candidate = activeTasks[(offset + i) % activeTasks.length];
      if (!usedCategories.contains(candidate.category)) {
        results.add(candidate);
        usedCategories.add(candidate.category);
      }
    }

    // Second pass: fill remaining slots if needed
    for (int i = 0; i < activeTasks.length && results.length < count; i++) {
      final candidate = activeTasks[(offset + i) % activeTasks.length];
      if (!results.any((r) => r.id == candidate.id)) {
        results.add(candidate);
      }
    }

    return results;
  }
}
