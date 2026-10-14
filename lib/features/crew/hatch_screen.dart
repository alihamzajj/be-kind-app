import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/settings/app_settings.dart';
import '../../core/voice/voice_greeting.dart';
import '../../core/widgets/motion.dart';
import 'art/crew_art.dart';
import 'controllers/crew_controller.dart';
import 'data/crew_roster.dart';
import 'engine/crew_engine.dart';
import 'models/crew_models.dart';
import 'widgets/character_view.dart';

/// Shows each waiting reveal: the egg shakes, cracks and bursts open, then
/// the new character says hello.
class HatchScreen extends ConsumerStatefulWidget {
  const HatchScreen({super.key});

  @override
  ConsumerState<HatchScreen> createState() => _HatchScreenState();
}

class _HatchScreenState extends ConsumerState<HatchScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF1C1842);

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..addListener(_onTick);
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  CrewReveal? _reveal;
  bool _revealed = false;
  int _lastCrack = 0;
  final _sparks = _Spark.burst(46);

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    final pending = ref.read(crewProvider).pendingReveals;
    _reveal = pending.isEmpty ? null : pending.first;
    _revealed = false;
    _lastCrack = 0;
    if (_reveal != null) _c.forward(from: 0);
  }

  void _onTick() {
    final crack = (_c.value / 0.5 * 4).floor().clamp(0, 4);
    if (crack > _lastCrack) {
      _lastCrack = crack;
      HapticFeedback.selectionClick();
    }
    if (!_revealed && _c.value >= 0.56) {
      _revealed = true;
      HapticFeedback.heavyImpact();
      final reveal = _reveal;
      if (reveal != null && ref.read(settingsProvider).voiceGreeting) {
        final c = crewCharacter(reveal.characterId);
        VoiceGreeting.instance.say(
          reveal.isNew
              ? 'Hi! I\'m ${c.name}! Nice to meet you!'
              : 'Hi again! It\'s me, ${c.name}!',
        );
      }
      setState(() {});
    }
  }

  /// Tap the egg to hatch it straight away.
  void _skipAhead() {
    if (_c.value < 0.5) _c.forward(from: 0.5);
  }

  Future<void> _next() async {
    await ref.read(crewProvider.notifier).consumeReveal();
    if (!mounted) return;
    if (ref.read(crewProvider).pendingReveals.isEmpty) {
      context.go('/today');
    } else {
      setState(_start);
    }
  }

  Future<void> _wear(String id) async {
    await ref.read(crewProvider.notifier).select(id);
    HapticFeedback.mediumImpact();
    await _next();
  }

  @override
  void dispose() {
    _c.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reveal = _reveal;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: reveal == null ? _empty(context) : _content(reveal),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.string(CrewArt.egg(), width: 110, height: 110),
            const SizedBox(height: 20),
            const Text(
              'No eggs ready yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Every kind act warms your egg. '
              'It hatches after ${CrewState.eggSize}.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/today'),
              child: const Text('Back to today'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(CrewReveal reveal) {
    final character = crewCharacter(reveal.characterId);
    final owned = ref.watch(crewProvider).owned[reveal.characterId];
    final isSelected = ref.watch(crewProvider).selectedId == character.id;
    final remaining = ref.watch(crewProvider).pendingReveals.length - 1;
    final still = reduceMotion(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_c, _spin]),
      builder: (context, _) {
        final t = still ? 1.0 : _c.value;
        final shakePhase = (t / 0.5).clamp(0.0, 1.0);
        final flash = t < 0.5
            ? 0.0
            : t < 0.58
            ? (t - 0.5) / 0.08
            : (1 - (t - 0.58) / 0.2).clamp(0.0, 1.0);
        final reveal01 = ((t - 0.56) / 0.44).clamp(0.0, 1.0);
        final pop = Curves.elasticOut.transform(reveal01);
        final textIn = Curves.easeOut.transform(
          ((t - 0.75) / 0.25).clamp(0.0, 1.0),
        );

        return Stack(
          children: [
            // Light rays behind the character.
            Positioned.fill(
              child: Opacity(
                opacity: reveal01,
                child: CustomPaint(
                  painter: _RaysPainter(
                    turn: _spin.value,
                    color: character.rarity == Rarity.legendary
                        ? const Color(0xFFFAC775)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _SparkPainter(_sparks, reveal01)),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  !_revealed
                      ? (reveal.fromMilestone
                            ? 'A special egg appeared!'
                            : 'Your egg is hatching…')
                      : reveal.fromMilestone
                      ? 'Milestone friend unlocked!'
                      : reveal.isNew
                      ? 'Your egg hatched!'
                      : 'An old friend came to visit',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: !_revealed
                        ? GestureDetector(
                            onTap: _skipAhead,
                            child: Transform.rotate(
                              angle:
                                  math.sin(shakePhase * math.pi * 14) *
                                  0.05 *
                                  (0.4 + shakePhase * 1.6),
                              alignment: Alignment.bottomCenter,
                              child: SvgPicture.string(
                                CrewArt.egg(
                                  warmth: (shakePhase * 4).floor(),
                                  glowing: true,
                                ),
                                width: 190,
                                height: 190,
                              ),
                            ),
                          )
                        : Transform.scale(
                            scale: 0.3 + 0.7 * pop,
                            child: Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: character.tint,
                                border: Border.all(
                                  color: reveal.shiny
                                      ? const Color(0xFFEF9F27)
                                      : Colors.white,
                                  width: 5,
                                ),
                              ),
                              padding: const EdgeInsets.only(top: 22),
                              child: CharacterView(
                                character: character,
                                size: 190,
                                stage: owned?.stage ?? BondStage.baby,
                                shiny: reveal.shiny,
                                onTap: () => VoiceGreeting.instance.say(
                                  character.lines.first,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Opacity(
                  opacity: _revealed ? textIn : 0,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - textIn)),
                    child: _details(
                      character,
                      reveal,
                      owned,
                      isSelected,
                      remaining,
                    ),
                  ),
                ),
              ],
            ),
            // White flash as the shell bursts.
            if (flash > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.white.withValues(alpha: flash * 0.9),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _details(
    CrewCharacter character,
    CrewReveal reveal,
    OwnedCharacter? owned,
    bool isSelected,
    int remaining,
  ) {
    final (rarityBg, rarityFg) = character.rarity.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _Chip(label: character.rarity.label, bg: rarityBg, fg: rarityFg),
              if (reveal.isNew)
                const _Chip(
                  label: 'New',
                  bg: AppColors.lime,
                  fg: AppColors.onLime,
                ),
              if (reveal.shiny)
                const _Chip(
                  label: '✨ Shiny',
                  bg: Color(0xFFFAEEDA),
                  fg: Color(0xFF633806),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${character.name} the ${character.species}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reveal.isNew
                ? '${character.title[0].toUpperCase()}'
                      '${character.title.substring(1)} · ${character.kind}'
                : '+${CrewEngine.duplicateBond} bond · now level ${owned?.level ?? 1}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '“${character.lines.first}”',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              fontStyle: FontStyle.italic,
              color: Color(0xFFCECBF6),
            ),
          ),
          const SizedBox(height: 22),
          if (!isSelected)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _wear(character.id),
                icon: const Icon(Icons.account_circle_outlined),
                label: const Text('Set as profile picture'),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _next,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size(48, 50),
              ),
              child: Text(
                remaining > 0
                    ? 'Next surprise ($remaining more)'
                    : isSelected
                    ? 'Continue'
                    : 'Maybe later',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter({required this.turn, required this.color});

  final double turn;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = size.longestSide;
    final paint = Paint()..color = color.withValues(alpha: 0.07);
    const rays = 14;
    for (var i = 0; i < rays; i++) {
      final a = turn * 2 * math.pi + i * 2 * math.pi / rays;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + radius * math.cos(a - 0.09),
          center.dy + radius * math.sin(a - 0.09),
        )
        ..lineTo(
          center.dx + radius * math.cos(a + 0.09),
          center.dy + radius * math.sin(a + 0.09),
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) =>
      old.turn != turn || old.color != color;
}

class _Spark {
  _Spark(this.angle, this.speed, this.size, this.color);

  final double angle;
  final double speed;
  final double size;
  final Color color;

  static List<_Spark> burst(int n) {
    final rng = math.Random(7);
    const colors = [
      Color(0xFF9FE870),
      Color(0xFFFAC775),
      Color(0xFFF4C0D1),
      Color(0xFFAFA9EC),
      Colors.white,
    ];
    return List.generate(
      n,
      (_) => _Spark(
        rng.nextDouble() * 2 * math.pi,
        0.5 + rng.nextDouble() * 0.6,
        2 + rng.nextDouble() * 4,
        colors[rng.nextInt(colors.length)],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.sparks, this.t);

  final List<_Spark> sparks;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = Offset(size.width / 2, size.height * 0.42);
    final reach = size.shortestSide * 0.62;
    final eased = Curves.easeOutCubic.transform(t);
    for (final s in sparks) {
      final d = reach * s.speed * eased;
      final p = center + Offset(math.cos(s.angle) * d, math.sin(s.angle) * d);
      canvas.drawCircle(
        p,
        s.size * (1 - t * 0.5),
        Paint()..color = s.color.withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.t != t;
}
