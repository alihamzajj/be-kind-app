import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/motion.dart';
import '../art/crew_art.dart';
import '../controllers/crew_controller.dart';
import '../models/crew_models.dart';

/// A living character: breathes, blinks now and then, and jumps with a
/// wiggle when tapped.
class CharacterView extends StatefulWidget {
  const CharacterView({
    required this.character,
    this.size = 96,
    this.stage = BondStage.baby,
    this.shiny = false,
    this.silhouette = false,
    this.animate = true,
    this.onTap,
    super.key,
  });

  final CrewCharacter character;
  final double size;
  final BondStage stage;
  final bool shiny;
  final bool silhouette;
  final bool animate;

  /// Called after the tap reaction starts.
  final VoidCallback? onTap;

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView>
    with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final AnimationController _jump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  final _rng = math.Random();
  Timer? _blinkTimer;
  bool _blinking = false;
  late String _open;
  late String _closed;

  bool get _alive => widget.animate && !widget.silhouette;

  @override
  void initState() {
    super.initState();
    _buildArt();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_alive && !reduceMotion(context)) {
      if (!_breath.isAnimating) _breath.repeat(reverse: true);
      _scheduleBlink();
    } else {
      _breath.stop();
      _blinkTimer?.cancel();
    }
  }

  @override
  void didUpdateWidget(CharacterView old) {
    super.didUpdateWidget(old);
    if (old.character.id != widget.character.id ||
        old.stage != widget.stage ||
        old.shiny != widget.shiny ||
        old.silhouette != widget.silhouette) {
      _buildArt();
    }
  }

  void _buildArt() {
    String art(bool blink) => CrewArt.character(
      widget.character,
      stage: widget.stage,
      shiny: widget.shiny,
      silhouette: widget.silhouette,
      blink: blink,
    );
    _open = art(false);
    _closed = art(true);
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: 2200 + _rng.nextInt(3200)), () {
      if (!mounted) return;
      setState(() => _blinking = true);
      _blinkTimer = Timer(const Duration(milliseconds: 140), () {
        if (!mounted) return;
        setState(() => _blinking = false);
        _scheduleBlink();
      });
    });
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    if (_alive && !reduceMotion(context)) _jump.forward(from: 0);
    widget.onTap!();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _breath.dispose();
    _jump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.string(
      _blinking ? _closed : _open,
      width: widget.size,
      height: widget.size,
    );
    final body = AnimatedBuilder(
      animation: Listenable.merge([_breath, _jump]),
      child: picture,
      builder: (context, child) {
        final breath = Curves.easeInOut.transform(_breath.value);
        final j = _jump.value;
        final lift = math.sin(math.pi * j) * widget.size * 0.14;
        final wiggle = math.sin(4 * math.pi * j) * 0.12 * (1 - j);
        return Transform.translate(
          offset: Offset(0, -lift),
          child: Transform.rotate(
            angle: wiggle,
            child: Transform.scale(
              scaleX: 1 + 0.015 * breath,
              scaleY: 1 + 0.035 * breath,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
    return Semantics(
      label: widget.silhouette
          ? 'Locked character'
          : '${widget.character.name} the ${widget.character.species}',
      image: true,
      child: widget.onTap == null
          ? body
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleTap,
              child: body,
            ),
    );
  }
}

/// Round profile picture showing the selected character.
class CrewAvatar extends ConsumerWidget {
  const CrewAvatar({
    this.size = 48,
    this.onTap,
    this.fallbackInitials = '',
    this.animate = true,
    super.key,
  });

  final double size;
  final VoidCallback? onTap;
  final String fallbackInitials;
  final bool animate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCharacterProvider);
    final Widget content;
    final Color bg;
    if (selected == null) {
      bg = AppColors.lime;
      content = Center(
        child: Text(
          fallbackInitials,
          style: TextStyle(
            fontSize: size * 0.32,
            fontWeight: FontWeight.w800,
            color: AppColors.onLime,
          ),
        ),
      );
    } else {
      bg = selected.character.tint;
      content = Padding(
        padding: EdgeInsets.only(top: size * 0.1),
        child: CharacterView(
          character: selected.character,
          size: size * 0.86,
          stage: selected.owned.stage,
          shiny: selected.owned.shiny,
          animate: animate,
        ),
      );
    }
    final shiny = selected?.owned.shiny ?? false;
    final avatar = Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(
          color: shiny ? const Color(0xFFEF9F27) : AppColors.surface,
          width: size > 60 ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Align(alignment: Alignment.bottomCenter, child: content),
    );
    return Semantics(
      button: onTap != null,
      label: selected == null
          ? 'Profile'
          : 'Your character, ${selected.character.name}',
      child: onTap == null
          ? avatar
          : GestureDetector(onTap: onTap, child: avatar),
    );
  }
}

/// The mystery egg, wobbling more as it gets close to hatching.
class EggView extends StatefulWidget {
  const EggView({required this.warmth, this.size = 56, super.key});

  final int warmth;
  final double size;

  @override
  State<EggView> createState() => _EggViewState();
}

class _EggViewState extends State<EggView> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nearlyThere = widget.warmth >= CrewState.eggSize - 1;
    final picture = SvgPicture.string(
      CrewArt.egg(warmth: widget.warmth, glowing: nearlyThere),
      width: widget.size,
      height: widget.size,
    );
    return Semantics(
      label: 'Mystery egg, ${widget.warmth} of ${CrewState.eggSize} warm',
      image: true,
      child: AnimatedBuilder(
        animation: _c,
        child: picture,
        builder: (context, child) {
          // A little shake every cycle; bigger when it's about to hatch.
          final t = _c.value;
          final active = t < 0.35 ? math.sin(t / 0.35 * math.pi * 4) : 0.0;
          final amp = nearlyThere ? 0.16 : 0.04 + 0.025 * widget.warmth;
          return Transform.rotate(
            angle: active * amp,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        },
      ),
    );
  }
}
