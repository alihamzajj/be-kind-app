import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/voice/voice_greeting.dart';
import '../../core/widgets/ui.dart';
import 'controllers/crew_controller.dart';
import 'data/crew_roster.dart';
import 'models/crew_models.dart';
import 'widgets/character_view.dart';

/// "My characters": the current profile character, the egg, and the full
/// collection with locked ones as silhouettes.
class CrewScreen extends ConsumerWidget {
  const CrewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crew = ref.watch(crewProvider);
    final selected = ref.watch(selectedCharacterProvider);
    final hPad = pagePadding(context);
    final found = crew.owned.length;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 840 ? 5 : (width >= 600 ? 4 : 3);

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
              children: [
                PageHeader(
                  title: 'My characters',
                  subtitle: '$found of ${kCrew.length} found',
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go('/today'),
                ),
                const SizedBox(height: 18),
                if (selected != null)
                  _CurrentCard(
                    character: selected.character,
                    owned: selected.owned,
                  ),
                const SizedBox(height: 12),
                _EggCard(crew: crew),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Collection',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontSize: 22),
                      ),
                    ),
                    Text(
                      '$found / ${kCrew.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: found / kCrew.length,
                    minHeight: 8,
                    backgroundColor: AppColors.track,
                    valueColor: AlwaysStoppedAnimation(AppColors.positive),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.74,
                  children: [
                    for (final c in kCrew)
                      _CollectionCard(
                        character: c,
                        owned: crew.owned[c.id],
                        selected: crew.selectedId == c.id,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.character, required this.owned});

  final CrewCharacter character;
  final OwnedCharacter owned;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: character.tint,
      onTap: () => showCharacterSheet(context, character.id),
      child: Row(
        children: [
          CharacterView(
            character: character,
            size: 104,
            stage: owned.stage,
            shiny: owned.shiny,
            onTap: () => VoiceGreeting.instance.say(character.lines.first),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your profile picture',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A6C6A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  character.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Color(0xFF0E0F0C),
                  ),
                ),
                Text(
                  '${owned.stage.label} · Level ${owned.level}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF454745),
                  ),
                ),
                const SizedBox(height: 10),
                _BondBar(owned: owned, onLight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BondBar extends StatelessWidget {
  const _BondBar({required this.owned, this.onLight = false});

  final OwnedCharacter owned;

  /// True when drawn on a fixed light tint rather than the themed page.
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final muted = onLight ? const Color(0xFF6A6C6A) : AppColors.muted;
    final maxed = owned.level >= OwnedCharacter.maxLevel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: owned.levelProgress,
            minHeight: 7,
            backgroundColor: onLight
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.track,
            valueColor: const AlwaysStoppedAnimation(Color(0xFFEF9F27)),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          maxed
              ? 'Max bond. A true hero!'
              : '${owned.xpToNextLevel} more kind '
                    '${owned.xpToNextLevel == 1 ? 'act' : 'acts'} together '
                    'to level ${owned.level + 1}',
          style: TextStyle(fontSize: 12, color: muted),
        ),
      ],
    );
  }
}

class _EggCard extends StatelessWidget {
  const _EggCard({required this.crew});

  final CrewState crew;

  @override
  Widget build(BuildContext context) {
    final left = crew.actsToHatch;
    return SoftCard(
      child: Row(
        children: [
          EggView(warmth: crew.eggWarmth, size: 60),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mystery egg',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  left == 1
                      ? 'Hatches after your next kind act!'
                      : 'Hatches in $left kind acts',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < CrewState.eggSize; i++)
                      Expanded(
                        child: Container(
                          height: 7,
                          margin: EdgeInsets.only(
                            right: i < CrewState.eggSize - 1 ? 4 : 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: i < crew.eggWarmth
                                ? const Color(0xFF7F77DD)
                                : AppColors.track,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.character,
    required this.owned,
    required this.selected,
  });

  final CrewCharacter character;
  final OwnedCharacter? owned;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final owned = this.owned;
    final locked = owned == null;
    final (rarityBg, rarityFg) = character.rarity.colors;
    final radius = BorderRadius.circular(20);

    return Material(
      color: locked ? AppColors.card : character.tint,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          HapticFeedback.selectionClick();
          if (locked) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Locked · ${character.unlockHint}')),
              );
          } else {
            showCharacterSheet(context, character.id);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: selected
                ? Border.all(color: AppColors.positive, width: 2.5)
                : null,
          ),
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (context, box) => CharacterView(
                        character: character,
                        size: box.biggest.shortestSide,
                        stage: owned?.stage ?? BondStage.baby,
                        shiny: owned?.shiny ?? false,
                        silhouette: locked,
                        animate: false,
                      ),
                    ),
                    if (locked)
                      Icon(
                        Icons.lock_rounded,
                        size: 20,
                        color: AppColors.surface,
                      ),
                    if (owned?.shiny ?? false)
                      const Positioned(
                        top: 0,
                        right: 2,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Color(0xFFEF9F27),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                locked ? '???' : character.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: locked ? AppColors.muted : const Color(0xFF0E0F0C),
                ),
              ),
              const SizedBox(height: 3),
              if (selected)
                const _MiniTag(
                  label: 'Profile',
                  bg: AppColors.lime,
                  fg: AppColors.onLime,
                )
              else if (locked)
                Text(
                  character.unlockHint,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                )
              else
                _MiniTag(
                  label: character.rarity.label,
                  bg: rarityBg,
                  fg: rarityFg,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

/// Details for one collected character: story, growth, and a button to
/// wear it as the profile picture.
Future<void> showCharacterSheet(BuildContext context, String id) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CharacterSheet(id: id),
  );
}

class _CharacterSheet extends ConsumerWidget {
  const _CharacterSheet({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crew = ref.watch(crewProvider);
    final owned = crew.owned[id];
    final character = crewCharacter(id);
    if (owned == null) return const SizedBox.shrink();
    final isSelected = crew.selectedId == id;
    final (rarityBg, rarityFg) = character.rarity.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lineStrong,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: character.tint,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: CharacterView(
                character: character,
                size: 170,
                stage: owned.stage,
                shiny: owned.shiny,
                onTap: () {
                  final lines = character.lines;
                  VoiceGreeting.instance.say(
                    lines[DateTime.now().millisecond % lines.length],
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to hear ${character.name}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MiniTag(
                  label: character.rarity.label,
                  bg: rarityBg,
                  fg: rarityFg,
                ),
                _MiniTag(
                  label: character.kind,
                  bg: AppColors.accentSoft,
                  fg: AppColors.accent,
                ),
                if (owned.shiny)
                  const _MiniTag(
                    label: '✨ Shiny',
                    bg: Color(0xFFFAEEDA),
                    fg: Color(0xFF633806),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${character.name} the ${character.species}',
              style: textTheme.headlineMedium?.copyWith(fontSize: 26),
            ),
            Text(
              character.title[0].toUpperCase() + character.title.substring(1),
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            Text(character.bio, style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bond · level ${owned.level} ${owned.stage.label}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _BondBar(owned: owned),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (final stage in BondStage.values)
                        _StageStep(
                          character: character,
                          stage: stage,
                          reached: owned.stage.index >= stage.index,
                          shiny: owned.shiny,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Met on ${formatShortDate(owned.hatchedAt)}',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            if (isSelected)
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Your profile picture'),
              )
            else
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(crewProvider.notifier).select(id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${character.name} is your profile picture'),
                    ),
                  );
                },
                icon: const Icon(Icons.account_circle_outlined),
                label: const Text('Use as profile picture'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StageStep extends StatelessWidget {
  const _StageStep({
    required this.character,
    required this.stage,
    required this.reached,
    required this.shiny,
  });

  final CrewCharacter character;
  final BondStage stage;
  final bool reached;
  final bool shiny;

  @override
  Widget build(BuildContext context) {
    const levels = {
      BondStage.baby: 'Lv 1',
      BondStage.buddy: 'Lv 5',
      BondStage.hero: 'Lv 10',
    };
    return Column(
      children: [
        Opacity(
          opacity: reached ? 1 : 0.35,
          child: CharacterView(
            character: character,
            size: 56,
            stage: stage,
            shiny: shiny,
            animate: false,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stage.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: reached ? AppColors.ink : AppColors.muted,
          ),
        ),
        Text(
          reached ? levels[stage]! : '🔒 ${levels[stage]!}',
          style: TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
