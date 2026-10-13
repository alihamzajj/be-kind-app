import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/kindness_tasks/models/kindness_task.dart';
import '../../features/kindness_tasks/services/daily_task_selector.dart';
import '../../features/streaks/engine/streak_engine.dart';
import '../settings/app_settings.dart';

/// Schedules the morning reminder and optional evening nudge.
///
/// Reminders are one-shot notifications for the next [_horizonDays] days so
/// each can name that day's kind act; they are rescheduled on every launch,
/// settings change and completion.
class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  static const _horizonDays = 14;
  static const _morningBase = 1000;
  static const _eveningBase = 2000;
  static const _eveningHour = 19;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Inexact alarms can arrive many hours late, so use exact ones whenever
  /// Android lets us (always below Android 12; needs the "Alarms &
  /// reminders" permission from 12 on).
  AndroidScheduleMode _scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (!_supported || _ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Unknown zone name: fall back to UTC offsets via tz.local default.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_heart'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Asks the OS for permission to post notifications. Returns true if granted.
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    await init();
    final android = _android;
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      if (granted && await android.canScheduleExactNotifications() != true) {
        await android.requestExactAlarmsPermission();
      }
      return granted;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_kind_act',
      'Daily kind act',
      channelDescription: 'Your morning reminder and evening nudge',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      color: Color(0xFF163300),
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Replaces every scheduled reminder to match [settings].
  Future<void> sync({
    required AppSettings settings,
    required List<KindnessTask> library,
    required bool todayDone,
  }) async {
    if (!_supported) return;
    await init();
    await _plugin.cancelAllPendingNotifications();
    if (!settings.reminderEnabled || library.isEmpty) return;

    final android = _android;
    if (android != null) {
      _scheduleMode = await android.canScheduleExactNotifications() == false
          ? AndroidScheduleMode.inexactAllowWhileIdle
          : AndroidScheduleMode.exactAllowWhileIdle;
    }

    final now = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < _horizonDays; i++) {
      final day = now.add(Duration(days: i));
      if (!settings.reminderDays.contains(day.weekday)) continue;
      final task = DailyTaskSelector.selectPrimaryTask(
        allTasks: library,
        localDate: StreakEngine.formatLocalDate(
          DateTime(day.year, day.month, day.day),
        ),
      );

      final morning = tz.TZDateTime(
        tz.local,
        day.year,
        day.month,
        day.day,
        settings.reminderHour,
        settings.reminderMinute,
      );
      if (morning.isAfter(now) && !(i == 0 && todayDone)) {
        await _schedule(
          _morningBase + i,
          morning,
          'Your kind act for today is ready',
          '${task.title} · ${task.estimatedMinutes} min',
        );
      }

      if (settings.eveningNudge && !(i == 0 && todayDone)) {
        final evening = tz.TZDateTime(
          tz.local,
          day.year,
          day.month,
          day.day,
          _eveningHour,
        );
        if (evening.isAfter(now)) {
          await _schedule(
            _eveningBase + i,
            evening,
            'Still time for today’s kind act',
            'Keep your streak going: ${task.title}',
          );
        }
      }
    }
  }

  Future<void> _schedule(
    int id,
    tz.TZDateTime when,
    String title,
    String body,
  ) {
    return _plugin.zonedSchedule(
      id: id,
      scheduledDate: when,
      notificationDetails: _details,
      androidScheduleMode: _scheduleMode,
      title: title,
      body: body,
    );
  }

  /// Shows a sample reminder right away so the user can see what it looks like.
  Future<void> showPreview(KindnessTask? task) async {
    if (!_supported) return;
    await init();
    await _plugin.show(
      id: 999,
      title: 'Your kind act for today is ready',
      body: task == null
          ? 'Open Be Kind to see today’s act'
          : '${task.title} · ${task.estimatedMinutes} min',
      notificationDetails: _details,
    );
  }
}
