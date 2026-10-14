import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/controllers/daily_controller.dart';
import '../data/crew_roster.dart';
import '../engine/crew_engine.dart';
import '../models/crew_models.dart';

final crewProvider = NotifierProvider<CrewNotifier, CrewState>(
  CrewNotifier.new,
);

/// The profile-picture character, or null until the crew has loaded.
final selectedCharacterProvider =
    Provider<({CrewCharacter character, OwnedCharacter owned})?>((ref) {
      final crew = ref.watch(crewProvider);
      final id = crew.selectedId;
      final owned = id == null ? null : crew.owned[id];
      if (owned == null) return null;
      return (character: crewCharacter(id!), owned: owned);
    });

class CrewNotifier extends Notifier<CrewState> {
  static const _key = 'bekind_crew';
  final _rng = math.Random();
  late Future<void> _loaded;

  @override
  CrewState build() {
    _loaded = _load();
    ref.listen(dailyNotifierProvider, (_, daily) {
      if (!daily.isLoading) sync(daily);
    }, fireImmediately: true);
    return const CrewState();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        state = CrewState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Crew load failed, starting fresh: $e');
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  /// Counts any new kind acts. Safe to call repeatedly.
  Future<void> sync(DailyState daily) async {
    await _loaded;
    if (daily.isLoading) return;
    state = CrewEngine.sync(
      state,
      completions: daily.allCompletions,
      longestStreak: daily.streakResult.longestStreak,
      rng: _rng,
      now: DateTime.now(),
    );
    await _save();
  }

  Future<void> select(String id) async {
    if (!state.owned.containsKey(id)) return;
    state = state.copyWith(selectedId: id);
    await _save();
  }

  /// Removes the reveal that was just shown.
  Future<void> consumeReveal() async {
    if (state.pendingReveals.isEmpty) return;
    state = state.copyWith(pendingReveals: state.pendingReveals.sublist(1));
    await _save();
  }
}
