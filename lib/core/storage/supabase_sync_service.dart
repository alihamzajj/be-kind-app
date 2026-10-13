import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../../features/task_completion/models/task_completion.dart';
import '../../features/achievements/models/badge_models.dart';

class SupabaseSyncService {
  static SupabaseClient? get client {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static bool get isAuthenticated => client?.auth.currentUser != null;
  static User? get currentUser => client?.auth.currentUser;

  /// Syncs offline guest completions up to Supabase
  static Future<void> syncCompletions(List<TaskCompletion> completions) async {
    final sb = client;
    final user = currentUser;
    if (sb == null || user == null) return;

    for (final completion in completions) {
      try {
        await sb.from('task_completions').upsert({
          'user_id': user.id,
          'task_id': completion.taskId,
          'date': completion.localDate,
          'completed_at': completion.completedAt.toIso8601String(),
          'reflection': completion.privateNote,
        }, onConflict: 'user_id,date');
      } catch (e) {
        developer.log('Error syncing completion: $e', name: 'SupabaseSyncService');
      }
    }
  }

  /// Syncs earned badges up to Supabase
  static Future<void> syncBadges(List<UserBadgeProgress> badges) async {
    final sb = client;
    final user = currentUser;
    if (sb == null || user == null) return;

    final earnedBadges = badges.where((b) => b.isEarned);
    for (final badge in earnedBadges) {
      try {
        await sb.from('user_badges').upsert({
          'user_id': user.id,
          'badge_id': badge.definition.id,
          'unlocked_at': (badge.earnedAt ?? DateTime.now()).toIso8601String(),
        }, onConflict: 'user_id,badge_id');
      } catch (e) {
        developer.log('Error syncing badge: $e', name: 'SupabaseSyncService');
      }
    }
  }

  /// Updates streak metrics on the user's remote profile
  static Future<void> updateProfileStats({
    required int currentStreak,
    required int longestStreak,
    required int totalActs,
    String? fullName,
  }) async {
    final sb = client;
    final user = currentUser;
    if (sb == null || user == null) return;

    try {
      await sb.from('profiles').upsert({
        'id': user.id,
        ...?fullName != null ? {'full_name': fullName} : null,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_kind_acts': totalActs,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      developer.log('Error updating profile stats: $e', name: 'SupabaseSyncService');
    }
  }
}
