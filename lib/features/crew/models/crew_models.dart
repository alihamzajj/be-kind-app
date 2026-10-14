import 'package:flutter/material.dart';

enum Rarity { common, rare, epic, legendary }

extension RarityLabel on Rarity {
  String get label => switch (this) {
    Rarity.common => 'Common',
    Rarity.rare => 'Rare',
    Rarity.epic => 'Epic',
    Rarity.legendary => 'Legendary',
  };

  /// Chip colours: (background, text).
  (Color, Color) get colors => switch (this) {
    Rarity.common => (const Color(0xFFEDEDE9), const Color(0xFF454745)),
    Rarity.rare => (const Color(0xFFE6F1FB), const Color(0xFF0C447C)),
    Rarity.epic => (const Color(0xFFEEEDFE), const Color(0xFF3C3489)),
    Rarity.legendary => (const Color(0xFFFAEEDA), const Color(0xFF633806)),
  };
}

/// How grown-up a character looks, driven by its bond level.
enum BondStage { baby, buddy, hero }

extension BondStageLabel on BondStage {
  String get label => switch (this) {
    BondStage.baby => 'Baby',
    BondStage.buddy => 'Buddy',
    BondStage.hero => 'Hero',
  };
}

/// SVG fragments (64x64 canvas) that make up a character, layered back to
/// front. Eyes come in open and closed versions so the character can blink.
class CharacterArt {
  const CharacterArt({
    required this.body,
    required this.eyes,
    required this.blink,
    this.back = '',
    this.face = '',
    this.top = '',
  });

  final String back;
  final String body;
  final String eyes;
  final String blink;
  final String face;

  /// Head accessory; hidden once the character earns its hero crown.
  final String top;
}

class CrewCharacter {
  const CrewCharacter({
    required this.id,
    required this.name,
    required this.species,
    required this.title,
    required this.kind,
    required this.rarity,
    required this.bio,
    required this.lines,
    required this.doneLine,
    required this.unlockHint,
    required this.tint,
    required this.art,
    this.shinyColors = const {},
  });

  final String id;
  final String name;
  final String species;

  /// Short personality, e.g. "the thank-you expert".
  final String title;

  /// The kind of kindness it loves, or how it's earned.
  final String kind;
  final Rarity rarity;
  final String bio;

  /// Things it says on the Today screen.
  final List<String> lines;

  /// What it says once today's act is done.
  final String doneLine;

  /// Shown on its locked card.
  final String unlockHint;

  /// Soft background behind the character.
  final Color tint;
  final CharacterArt art;

  /// Colour swaps (uppercase hex) for the rare shiny version.
  final Map<String, String> shinyColors;

  /// Common and rare characters hatch from eggs; the rest are earned.
  bool get fromEgg => rarity == Rarity.common || rarity == Rarity.rare;
}

/// A character the user has collected.
class OwnedCharacter {
  const OwnedCharacter({
    required this.hatchedAt,
    this.shiny = false,
    this.bondXp = 0,
  });

  final DateTime hatchedAt;
  final bool shiny;

  /// One point per kind act done while this was the profile picture.
  final int bondXp;

  static const maxLevel = 10;
  static const xpPerLevel = 2;

  int get level => (1 + bondXp ~/ xpPerLevel).clamp(1, maxLevel);

  /// Progress from this level to the next, 0..1 (1 at max level).
  double get levelProgress =>
      level >= maxLevel ? 1 : (bondXp % xpPerLevel) / xpPerLevel;

  int get xpToNextLevel =>
      level >= maxLevel ? 0 : xpPerLevel - bondXp % xpPerLevel;

  BondStage get stage => level >= 10
      ? BondStage.hero
      : level >= 5
      ? BondStage.buddy
      : BondStage.baby;

  OwnedCharacter copyWith({bool? shiny, int? bondXp}) => OwnedCharacter(
    hatchedAt: hatchedAt,
    shiny: shiny ?? this.shiny,
    bondXp: bondXp ?? this.bondXp,
  );

  Map<String, dynamic> toJson() => {
    'hatchedAt': hatchedAt.toIso8601String(),
    'shiny': shiny,
    'bondXp': bondXp,
  };

  factory OwnedCharacter.fromJson(Map<String, dynamic> json) => OwnedCharacter(
    hatchedAt:
        DateTime.tryParse(json['hatchedAt'] as String? ?? '') ?? DateTime.now(),
    shiny: json['shiny'] as bool? ?? false,
    bondXp: json['bondXp'] as int? ?? 0,
  );
}

/// A character waiting to be shown on the hatch screen.
class CrewReveal {
  const CrewReveal({
    required this.characterId,
    required this.isNew,
    this.shiny = false,
    this.fromMilestone = false,
  });

  final String characterId;

  /// False when an egg gave a character the user already had.
  final bool isNew;
  final bool shiny;

  /// Earned by a streak or achievement rather than an egg.
  final bool fromMilestone;

  Map<String, dynamic> toJson() => {
    'id': characterId,
    'isNew': isNew,
    'shiny': shiny,
    'milestone': fromMilestone,
  };

  factory CrewReveal.fromJson(Map<String, dynamic> json) => CrewReveal(
    characterId: json['id'] as String,
    isNew: json['isNew'] as bool? ?? true,
    shiny: json['shiny'] as bool? ?? false,
    fromMilestone: json['milestone'] as bool? ?? false,
  );
}

class CrewState {
  const CrewState({
    this.initialized = false,
    this.owned = const {},
    this.selectedId,
    this.eggWarmth = 0,
    this.processedActs = 0,
    this.pendingReveals = const [],
  });

  /// Kind acts needed to hatch an egg.
  static const eggSize = 5;

  /// False until the first sync gives the starter character.
  final bool initialized;
  final Map<String, OwnedCharacter> owned;

  /// The character used as the profile picture.
  final String? selectedId;
  final int eggWarmth;

  /// Completions already counted, so each kind act is counted once.
  final int processedActs;
  final List<CrewReveal> pendingReveals;

  int get actsToHatch => eggSize - eggWarmth;

  CrewState copyWith({
    bool? initialized,
    Map<String, OwnedCharacter>? owned,
    String? selectedId,
    int? eggWarmth,
    int? processedActs,
    List<CrewReveal>? pendingReveals,
  }) => CrewState(
    initialized: initialized ?? this.initialized,
    owned: owned ?? this.owned,
    selectedId: selectedId ?? this.selectedId,
    eggWarmth: eggWarmth ?? this.eggWarmth,
    processedActs: processedActs ?? this.processedActs,
    pendingReveals: pendingReveals ?? this.pendingReveals,
  );

  Map<String, dynamic> toJson() => {
    'initialized': initialized,
    'owned': owned.map((k, v) => MapEntry(k, v.toJson())),
    'selectedId': selectedId,
    'eggWarmth': eggWarmth,
    'processedActs': processedActs,
    'pendingReveals': pendingReveals.map((r) => r.toJson()).toList(),
  };

  factory CrewState.fromJson(Map<String, dynamic> json) => CrewState(
    initialized: json['initialized'] as bool? ?? false,
    owned: (json['owned'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, OwnedCharacter.fromJson(v as Map<String, dynamic>)),
    ),
    selectedId: json['selectedId'] as String?,
    eggWarmth: json['eggWarmth'] as int? ?? 0,
    processedActs: json['processedActs'] as int? ?? 0,
    pendingReveals: (json['pendingReveals'] as List<dynamic>? ?? [])
        .map((e) => CrewReveal.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
