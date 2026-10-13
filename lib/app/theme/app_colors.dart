import 'package:flutter/material.dart';

/// One full set of colour tokens.
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.ground,
    required this.surface,
    required this.card,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.line,
    required this.lineStrong,
    required this.track,
    required this.accent,
    required this.accentSoft,
    required this.positive,
    required this.promo,
    required this.streak,
    required this.streakSoft,
  });

  final Brightness brightness;
  final Color ground;
  final Color surface;
  final Color card;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color line;
  final Color lineStrong;
  final Color track;

  /// Brand colour for text and icons on the page background.
  final Color accent;
  final Color accentSoft;
  final Color positive;
  final Color promo;
  final Color streak;
  final Color streakSoft;

  static const light = AppPalette(
    brightness: Brightness.light,
    ground: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFF0F0EC),
    ink: Color(0xFF0E0F0C),
    inkSoft: Color(0xFF454745),
    muted: Color(0xFF6A6C6A),
    line: Color(0xFFE8E8E4),
    lineStrong: Color(0xFFD3D3CE),
    track: Color(0xFFEDEDE9),
    accent: Color(0xFF163300),
    accentSoft: Color(0xFFE2F6D5),
    positive: Color(0xFF2F5711),
    promo: Color(0xFF3A0B12),
    streak: Color(0xFF8A3F12),
    streakSoft: Color(0xFFFBEADB),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    ground: Color(0xFF0E0F0C),
    surface: Color(0xFF0E0F0C),
    card: Color(0xFF1E201C),
    ink: Color(0xFFFFFFFF),
    inkSoft: Color(0xFFD0D2CE),
    muted: Color(0xFFA9ABA7),
    line: Color(0xFF262824),
    lineStrong: Color(0xFF3A3C38),
    track: Color(0xFF262824),
    accent: Color(0xFF9FE870),
    accentSoft: Color(0xFF22331A),
    positive: Color(0xFF9FE870),
    promo: Color(0xFF4A1019),
    streak: Color(0xFFFFB27A),
    streakSoft: Color(0xFF3A2416),
  );
}

/// Colour tokens for the active palette. Switch with [AppColors.use].
class AppColors {
  static AppPalette _p = AppPalette.light;

  static AppPalette get palette => _p;
  static void use(AppPalette palette) => _p = palette;

  static Color get ground => _p.ground;
  static Color get surface => _p.surface;
  static Color get card => _p.card;
  static Color get ink => _p.ink;
  static Color get inkSoft => _p.inkSoft;
  static Color get muted => _p.muted;
  static Color get line => _p.line;
  static Color get lineStrong => _p.lineStrong;
  static Color get track => _p.track;
  static Color get accent => _p.accent;
  static Color get accentDark => _p.accent;
  static Color get accentSoft => _p.accentSoft;
  static Color get accentOnSoft => _p.accent;
  static Color get positive => _p.positive;
  static Color get promo => _p.promo;
  static Color get streak => _p.streak;
  static Color get streakSoft => _p.streakSoft;

  /// Fixed in every palette.
  static const lime = Color(0xFF9FE870);

  /// Text and icons placed on [lime].
  static const onLime = Color(0xFF163300);
  static const error = Color(0xFFB3261E);
}
