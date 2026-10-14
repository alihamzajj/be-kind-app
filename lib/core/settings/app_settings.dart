import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences, stored on the device.
class AppSettings {
  const AppSettings({
    this.name,
    this.onboarded = false,
    this.themeMode = ThemeMode.system,
    this.reminderEnabled = false,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.reminderDays = const [1, 2, 3, 4, 5, 6, 7],
    this.eveningNudge = false,
    this.voiceGreeting = true,
  });

  final String? name;
  final bool onboarded;
  final ThemeMode themeMode;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  /// ISO weekdays (1 = Monday … 7 = Sunday).
  final List<int> reminderDays;
  final bool eveningNudge;

  /// Say "Hi" and the user's name out loud when the app opens.
  final bool voiceGreeting;

  String get displayName {
    final n = name?.trim();
    return (n == null || n.isEmpty) ? 'Friend' : n;
  }

  String get initials {
    final n = name?.trim() ?? '';
    if (n.isEmpty) return 'BK';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return n.substring(0, n.length >= 2 ? 2 : 1).toUpperCase();
  }

  AppSettings copyWith({
    String? name,
    bool? onboarded,
    ThemeMode? themeMode,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    List<int>? reminderDays,
    bool? eveningNudge,
    bool? voiceGreeting,
  }) {
    return AppSettings(
      name: name ?? this.name,
      onboarded: onboarded ?? this.onboarded,
      themeMode: themeMode ?? this.themeMode,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      reminderDays: reminderDays ?? this.reminderDays,
      eveningNudge: eveningNudge ?? this.eveningNudge,
      voiceGreeting: voiceGreeting ?? this.voiceGreeting,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'onboarded': onboarded,
    'themeMode': themeMode.name,
    'reminderEnabled': reminderEnabled,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'reminderDays': reminderDays,
    'eveningNudge': eveningNudge,
    'voiceGreeting': voiceGreeting,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      name: json['name'] as String?,
      onboarded: json['onboarded'] as bool? ?? false,
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderHour: json['reminderHour'] as int? ?? 8,
      reminderMinute: json['reminderMinute'] as int? ?? 0,
      reminderDays:
          (json['reminderDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      eveningNudge: json['eveningNudge'] as bool? ?? false,
      voiceGreeting: json['voiceGreeting'] as bool? ?? true,
    );
  }

  static const _key = 'bekind_settings';

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(toJson()));
  }
}

/// Settings loaded before the app starts; overridden in `main`.
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings(),
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    state = change(state);
    await state.save();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
