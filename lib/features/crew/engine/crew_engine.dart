import 'dart:math' as math;

import '../../task_completion/models/task_completion.dart';
import '../data/crew_roster.dart';
import '../models/crew_models.dart';

/// Pure rules for the Kindness Crew: everyone starts with Momo, each kind
/// act warms the egg and bonds the current character, full eggs hatch, and
/// streaks and variety earn the special characters.
class CrewEngine {
  CrewEngine._();

  static const starterId = 'momo';

  /// Chance that a new hatch is the shiny version.
  static const shinyOdds = 20;

  /// Chance (out of 100) that an egg rolls a rare character.
  static const rareChance = 20;

  /// Bond points a duplicate hatch gives instead of a new character.
  static const duplicateBond = 3;

  static const milestones = {
    'sunny': 'Reach a 7-day streak',
    'kiwi': 'Try 6 different kinds of kind acts',
    'nova': 'Reach a 30-day streak',
  };

  static CrewState sync(
    CrewState state, {
    required List<TaskCompletion> completions,
    required int longestStreak,
    required math.Random rng,
    required DateTime now,
  }) {
    var s = state;
    final acts = completions.length;

    if (!s.initialized) {
      // Existing users keep the warmth they've built up and get the eggs
      // their past kind acts would have hatched.
      s = CrewState(
        initialized: true,
        owned: {starterId: OwnedCharacter(hatchedAt: now)},
        selectedId: starterId,
        eggWarmth: acts % CrewState.eggSize,
        processedActs: acts,
      );
      for (var i = 0; i < acts ~/ CrewState.eggSize; i++) {
        s = _hatch(s, rng, now);
      }
    } else if (acts > s.processedActs) {
      final added = acts - s.processedActs;
      final owned = {...s.owned};
      final selected = s.selectedId == null ? null : owned[s.selectedId];
      if (selected != null) {
        owned[s.selectedId!] = selected.copyWith(
          bondXp: selected.bondXp + added,
        );
      }
      var warmth = s.eggWarmth + added;
      s = s.copyWith(owned: owned, processedActs: acts);
      while (warmth >= CrewState.eggSize) {
        warmth -= CrewState.eggSize;
        s = _hatch(s, rng, now);
      }
      s = s.copyWith(eggWarmth: warmth);
    } else if (acts < s.processedActs) {
      // History was cleared; start counting again from here.
      s = s.copyWith(processedActs: acts);
    }

    final kinds = completions.map((c) => c.category).toSet().length;
    s = _award(s, 'sunny', longestStreak >= 7, rng, now);
    s = _award(s, 'kiwi', kinds >= 6, rng, now);
    s = _award(s, 'nova', longestStreak >= 30, rng, now);
    return s;
  }

  static CrewState _award(
    CrewState s,
    String id,
    bool earned,
    math.Random rng,
    DateTime now,
  ) {
    if (!earned || s.owned.containsKey(id)) return s;
    final shiny = rng.nextInt(shinyOdds) == 0;
    return s.copyWith(
      owned: {
        ...s.owned,
        id: OwnedCharacter(hatchedAt: now, shiny: shiny),
      },
      pendingReveals: [
        ...s.pendingReveals,
        CrewReveal(
          characterId: id,
          isNew: true,
          shiny: shiny,
          fromMilestone: true,
        ),
      ],
    );
  }

  static CrewState _hatch(CrewState s, math.Random rng, DateTime now) {
    final unowned = kCrew
        .where((c) => c.fromEgg && !s.owned.containsKey(c.id))
        .toList();

    if (unowned.isEmpty) {
      // Collection complete: an old friend visits and grows a little.
      final eggFriends = kCrew
          .where((c) => c.fromEgg && s.owned.containsKey(c.id))
          .toList();
      final friend = eggFriends[rng.nextInt(eggFriends.length)];
      final had = s.owned[friend.id]!;
      return s.copyWith(
        owned: {
          ...s.owned,
          friend.id: had.copyWith(bondXp: had.bondXp + duplicateBond),
        },
        pendingReveals: [
          ...s.pendingReveals,
          CrewReveal(characterId: friend.id, isNew: false, shiny: had.shiny),
        ],
      );
    }

    final rares = unowned.where((c) => c.rarity == Rarity.rare).toList();
    final commons = unowned.where((c) => c.rarity == Rarity.common).toList();
    final rollRare = rng.nextInt(100) < rareChance;
    final pool = (rollRare && rares.isNotEmpty) || commons.isEmpty
        ? rares
        : commons;
    final picked = pool[rng.nextInt(pool.length)];
    final shiny = rng.nextInt(shinyOdds) == 0;
    return s.copyWith(
      owned: {
        ...s.owned,
        picked.id: OwnedCharacter(hatchedAt: now, shiny: shiny),
      },
      pendingReveals: [
        ...s.pendingReveals,
        CrewReveal(characterId: picked.id, isNew: true, shiny: shiny),
      ],
    );
  }
}
