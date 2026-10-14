import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:be_kind/features/crew/data/crew_roster.dart';
import 'package:be_kind/features/crew/engine/crew_engine.dart';
import 'package:be_kind/features/crew/models/crew_models.dart';
import 'package:be_kind/features/task_completion/models/task_completion.dart';

List<TaskCompletion> acts(int n, {List<String>? categories}) => List.generate(
  n,
  (i) => TaskCompletion(
    id: 'c$i',
    taskId: 't$i',
    taskTitle: 'Task $i',
    category: categories == null
        ? 'Gratitude'
        : categories[i % categories.length],
    localDate: '2026-01-${(i + 1).toString().padLeft(2, '0')}',
    completedAt: DateTime(2026, 1, i + 1),
  ),
);

CrewState run(
  CrewState s,
  List<TaskCompletion> completions, {
  int longest = 1,
  int seed = 1,
}) => CrewEngine.sync(
  s,
  completions: completions,
  longestStreak: longest,
  rng: math.Random(seed),
  now: DateTime(2026, 1, 1),
);

void main() {
  test('new users start with Momo as their profile picture', () {
    final s = run(const CrewState(), const []);
    expect(s.initialized, isTrue);
    expect(s.owned.keys, ['momo']);
    expect(s.selectedId, 'momo');
    expect(s.eggWarmth, 0);
    expect(s.pendingReveals, isEmpty);
  });

  test('existing users keep warmth and get eggs for past acts', () {
    final s = run(const CrewState(), acts(7));
    expect(s.eggWarmth, 2);
    expect(s.pendingReveals, hasLength(1));
    expect(s.owned, hasLength(2));
  });

  test('each act warms the egg and bonds the current character once', () {
    var s = run(const CrewState(), const []);
    s = run(s, acts(3));
    expect(s.eggWarmth, 3);
    expect(s.owned['momo']!.bondXp, 3);

    // Syncing again with the same history changes nothing.
    final again = run(s, acts(3));
    expect(again.eggWarmth, 3);
    expect(again.owned['momo']!.bondXp, 3);
  });

  test('the fifth act hatches a new egg character', () {
    var s = run(const CrewState(), acts(4));
    s = run(s, acts(5));
    expect(s.eggWarmth, 0);
    expect(s.pendingReveals, hasLength(1));
    final reveal = s.pendingReveals.single;
    expect(reveal.isNew, isTrue);
    expect(crewCharacter(reveal.characterId).fromEgg, isTrue);
    expect(s.owned.containsKey(reveal.characterId), isTrue);
  });

  test('streaks and variety unlock the special characters', () {
    var s = run(const CrewState(), const []);
    s = run(s, acts(1), longest: 7);
    expect(s.owned.containsKey('sunny'), isTrue);
    expect(s.pendingReveals.last.fromMilestone, isTrue);

    s = run(
      s,
      acts(
        6,
        categories: const [
          'Gratitude',
          'Community',
          'Environment',
          'Self-kindness',
          'Inclusion',
          'Family & Friends',
        ],
      ),
      longest: 30,
    );
    expect(s.owned.containsKey('kiwi'), isTrue);
    expect(s.owned.containsKey('nova'), isTrue);
  });

  test('with every egg character found, hatches strengthen old friends', () {
    final everyone = {
      for (final c in kCrew.where((c) => c.fromEgg))
        c.id: OwnedCharacter(hatchedAt: DateTime(2026)),
    };
    var s = CrewState(
      initialized: true,
      owned: everyone,
      selectedId: 'pip',
      eggWarmth: 4,
    );
    s = run(s, acts(1));
    final reveal = s.pendingReveals.single;
    expect(reveal.isNew, isFalse);
    final bond = s.owned[reveal.characterId]!.bondXp;
    expect(bond, greaterThanOrEqualTo(CrewEngine.duplicateBond));
  });

  test('bond levels grow the character from baby to hero', () {
    expect(OwnedCharacter(hatchedAt: DateTime(2026)).stage, BondStage.baby);
    expect(
      OwnedCharacter(hatchedAt: DateTime(2026), bondXp: 8).stage,
      BondStage.buddy,
    );
    final hero = OwnedCharacter(hatchedAt: DateTime(2026), bondXp: 18);
    expect(hero.stage, BondStage.hero);
    expect(hero.level, OwnedCharacter.maxLevel);
  });

  test('state survives a save and load', () {
    final s = run(const CrewState(), acts(6), longest: 7);
    final back = CrewState.fromJson(s.toJson());
    expect(back.owned.keys.toSet(), s.owned.keys.toSet());
    expect(back.eggWarmth, s.eggWarmth);
    expect(back.pendingReveals.length, s.pendingReveals.length);
    expect(back.selectedId, s.selectedId);
  });
}
