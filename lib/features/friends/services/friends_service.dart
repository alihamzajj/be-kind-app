import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/storage/supabase_sync_service.dart';
import '../models/friend_model.dart';

class FriendsService {
  static SupabaseClient? get _client => SupabaseSyncService.client;
  static User? get _currentUser => SupabaseSyncService.currentUser;

  /// Fetch user's friends from Supabase, or provide motivational community demo peers if guest/offline
  static Future<List<FriendModel>> fetchFriends() async {
    final client = _client;
    final user = _currentUser;

    if (client != null && user != null) {
      try {
        // Only people the user is actually connected with.
        final links = await client
            .from('friendships')
            .select('user_id, friend_id')
            .eq('status', 'accepted')
            .or('user_id.eq.${user.id},friend_id.eq.${user.id}');
        final ids = (links as List)
            .map((r) => r['user_id'] == user.id ? r['friend_id'] : r['user_id'])
            .whereType<String>()
            .toSet()
            .toList();
        if (ids.isEmpty) return const [];

        final res = await client.from('profiles').select().inFilter('id', ids);
        return (res as List)
            .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        developer.log('Error fetching friends: $e', name: 'FriendsService');
        return const [];
      }
    }

    // Guests see clearly-labelled examples of what Friends will look like.
    return const [
      FriendModel(
        id: 'demo_1',
        name: 'Sarah Jenkins',
        streak: 12,
        totalActs: 34,
        avatarUrl: null,
        lastActive: 'Today',
        isSample: true,
      ),
      FriendModel(
        id: 'demo_2',
        name: 'Marcus Chen',
        streak: 7,
        totalActs: 21,
        avatarUrl: null,
        lastActive: 'Today',
        isSample: true,
      ),
      FriendModel(
        id: 'demo_3',
        name: 'Elena Rostova',
        streak: 5,
        totalActs: 18,
        avatarUrl: null,
        lastActive: 'Yesterday',
        isSample: true,
      ),
    ];
  }

  /// Sends an encouraging cheer reaction to a friend
  static Future<bool> sendCheer(String friendId) async {
    final client = _client;
    final user = _currentUser;

    if (client != null && user != null) {
      try {
        await client.from('cheers').insert({
          'from_user_id': user.id,
          'to_user_id': friendId,
          'message': 'Proud of you! Keep going! ❤️',
        });
        return true;
      } catch (e) {
        developer.log('Error sending cheer: $e', name: 'FriendsService');
        return false;
      }
    }
    return true; // Example friends: the cheer stays local
  }
}
