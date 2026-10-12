import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:be_kind/features/kindness_tasks/models/kindness_task.dart';
import 'package:be_kind/features/task_completion/models/task_completion.dart';

class LocalDataService {
  static const String _keyCompletions = 'bekind_task_completions';
  static const String _keySelectedTaskPrefix = 'bekind_selected_task_'; // suffix: YYYY-MM-DD
  static const String _keyEarnedBadges = 'bekind_earned_badges';

  List<KindnessTask>? _cachedLibrary;

  /// Loads the 30+ curated tasks from the JSON asset
  Future<List<KindnessTask>> loadTaskLibrary() async {
    if (_cachedLibrary != null) return _cachedLibrary!;
    final jsonString = await rootBundle.loadString('assets/tasks/kindness_tasks.json');
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    _cachedLibrary = list
        .map((e) => KindnessTask.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedLibrary!;
  }

  /// Gets all recorded completions
  Future<List<TaskCompletion>> getCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyCompletions) ?? [];
    return jsonList
        .map((str) => TaskCompletion.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  /// Records a completion idempotently for a given local date.
  /// If a completion already exists for [localDate], returns the existing completion without duplicating.
  Future<TaskCompletion> recordCompletion({
    required KindnessTask task,
    required String localDate,
    String? note,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getCompletions();

    // Idempotency check: see if a completion for localDate already exists
    final existingIndex = currentList.indexWhere((c) => c.localDate == localDate);
    if (existingIndex != -1) {
      // Already completed for this date: update note if provided, return existing record
      final existing = currentList[existingIndex];
      if (note != null && note.isNotEmpty && note != existing.privateNote) {
        final updated = TaskCompletion(
          id: existing.id,
          taskId: existing.taskId,
          taskTitle: existing.taskTitle,
          category: existing.category,
          localDate: existing.localDate,
          completedAt: existing.completedAt,
          privateNote: note,
        );
        currentList[existingIndex] = updated;
        final rawList = currentList.map((c) => jsonEncode(c.toJson())).toList();
        await prefs.setStringList(_keyCompletions, rawList);
        return updated;
      }
      return existing;
    }

    final newCompletion = TaskCompletion(
      id: 'comp_${DateTime.now().millisecondsSinceEpoch}_${task.id}',
      taskId: task.id,
      taskTitle: task.title,
      category: task.category,
      localDate: localDate,
      completedAt: DateTime.now(),
      privateNote: note,
    );

    currentList.add(newCompletion);
    final rawList = currentList.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_keyCompletions, rawList);
    return newCompletion;
  }

  /// Gets the user's selected/swapped task ID for a given date
  Future<String?> getSelectedTaskIdForDate(String localDate) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keySelectedTaskPrefix$localDate');
  }

  /// Saves the user's selected/swapped task ID for a given date
  Future<void> setSelectedTaskIdForDate(String localDate, String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keySelectedTaskPrefix$localDate', taskId);
  }

  /// Gets earned badge IDs and timestamps
  Future<Map<String, String>> getEarnedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyEarnedBadges);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  /// Records an earned badge if not already earned
  Future<void> recordEarnedBadge(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final badges = await getEarnedBadges();
    if (!badges.containsKey(badgeId)) {
      badges[badgeId] = DateTime.now().toIso8601String();
      await prefs.setString(_keyEarnedBadges, jsonEncode(badges));
    }
  }

  /// Resets all local guest data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
