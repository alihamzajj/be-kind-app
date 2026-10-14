import '../models/crew_models.dart';

/// Builds SVG markup for characters and eggs.
class CrewArt {
  CrewArt._();

  static const _open =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">';
  static const _close = '</svg>';

  // Outfits earned by growing up.
  static const _cape =
      '<path d="M10 40 Q4 62 18 63 L46 63 Q60 62 54 40Z" fill="#534AB7"/>'
      '<path d="M14 44 Q10 60 20 61 L24 61 Q16 54 18 44Z" fill="#7F77DD"/>';
  static const _scarf =
      '<path d="M14 50 Q32 59 50 50 L50 55 Q32 64 14 55Z" fill="#E24B4A"/>'
      '<rect x="39" y="53" width="6" height="10" rx="2" fill="#A32D2D"/>';
  static const _crown =
      '<path d="M23 10 L26.5 14 L32 6 L37.5 14 L41 10 L40 17 H24Z" fill="#EF9F27" '
      'stroke="#BA7517" stroke-width="0.8"/>'
      '<circle cx="32" cy="6" r="1.3" fill="#E24B4A"/>';

  static final _hex = RegExp(r'#[0-9A-F]{6}');
  static final _paint = RegExp(r'(fill|stroke)="#[0-9A-F]{6}"');

  static String character(
    CrewCharacter c, {
    BondStage stage = BondStage.baby,
    bool shiny = false,
    bool blink = false,
    bool silhouette = false,
  }) {
    final a = c.art;
    final b = StringBuffer(_open);
    if (stage == BondStage.hero && !silhouette) b.write(_cape);
    b
      ..write(a.back)
      ..write(a.body)
      ..write(blink ? a.blink : a.eyes)
      ..write(a.face);
    if (!silhouette) {
      if (stage != BondStage.baby) b.write(_scarf);
      b.write(stage == BondStage.hero ? _crown : a.top);
    }
    b.write(_close);
    var svg = b.toString();
    if (shiny && c.shinyColors.isNotEmpty) {
      // One pass, so swapped colours aren't swapped again.
      svg = svg.replaceAllMapped(_hex, (m) => c.shinyColors[m[0]!] ?? m[0]!);
    }
    if (silhouette) {
      svg = svg.replaceAllMapped(_paint, (m) => '${m[1]}="#A7A9A4"');
    }
    return svg;
  }

  /// A speckled egg; [warmth] of [CrewState.eggSize] adds cracks.
  static String egg({int warmth = 0, bool glowing = false}) {
    final b = StringBuffer(_open);
    if (glowing) {
      b.write('<circle cx="32" cy="36" r="28" fill="#EEEDFE"/>');
    }
    b.write(
      '<ellipse cx="32" cy="37" rx="19" ry="24" fill="#F7F5FF" stroke="#7F77DD" stroke-width="2"/>'
      '<circle cx="24" cy="27" r="4" fill="#CECBF6"/>'
      '<circle cx="40" cy="34" r="5" fill="#AFA9EC"/>'
      '<circle cx="27" cy="46" r="3.4" fill="#CECBF6"/>'
      '<circle cx="39" cy="49" r="2.4" fill="#AFA9EC"/>'
      '<path d="M18 30 Q22 22 26 18" stroke="#FFFFFF" stroke-width="2.4" '
      'fill="none" stroke-linecap="round"/>',
    );
    const cracks = [
      'M32 14 L29 20 L33 23',
      'M33 23 L30 28',
      'M14 38 L19 36 L21 40 L25 38',
      'M50 33 L45 36 L46 40 L42 42',
    ];
    for (var i = 0; i < warmth.clamp(0, cracks.length); i++) {
      b.write(
        '<path d="${cracks[i]}" stroke="#534AB7" stroke-width="1.6" '
        'fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
      );
    }
    b.write(_close);
    return b.toString();
  }
}
