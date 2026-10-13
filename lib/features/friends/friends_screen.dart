import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/app_colors.dart';
import '../../core/storage/supabase_sync_service.dart';
import '../../core/widgets/ui.dart';
import 'models/friend_model.dart';
import 'services/friends_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<FriendModel> _friends = [];
  bool _isLoading = true;
  final Set<String> _cheeredFriends = {};

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final list = await FriendsService.fetchFriends();
    if (mounted) {
      setState(() {
        _friends = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _inviteFriend() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Join me on Be Kind! Let\'s build a daily kindness streak together: https://bekind.app/invite',
      ),
    );
  }

  Future<void> _sendCheer(FriendModel friend) async {
    if (_cheeredFriends.contains(friend.id)) return;

    setState(() {
      _cheeredFriends.add(friend.id);
    });

    await FriendsService.sendCheer(friend.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent a cheer to ${friend.name}! 🎉'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = pagePadding(context);
    final textTheme = Theme.of(context).textTheme;
    final isOnline = SupabaseSyncService.isAuthenticated;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFriends,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Friends & Community',
                  trailing: RoundIconButton(
                    icon: Icons.person_add_alt_1,
                    tooltip: 'Invite a Friend',
                    onTap: _inviteFriend,
                  ),
                ),
                const SizedBox(height: 14),

                // Top Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _inviteFriend,
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Invite Friend'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _loadFriends,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Community Kindness Streaks Section
                const SectionHeader(title: 'Active Streaks'),
                const SizedBox(height: 10),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_friends.isEmpty)
                  SoftCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.people_outline, size: 48, color: AppColors.muted),
                          const SizedBox(height: 12),
                          const Text(
                            'No friends connected yet',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Invite a friend to cheer each other on!',
                            style: TextStyle(color: AppColors.inkSoft),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final friend in _friends)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.accentSoft,
                            child: Text(
                              friend.name.isNotEmpty
                                  ? friend.name[0].toUpperCase()
                                  : 'F',
                              style: TextStyle(
                                color: AppColors.accentOnSoft,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friend.name,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_fire_department,
                                          size: 15,
                                          color: AppColors.streak,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '${friend.streak}d streak',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.streak,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '•  ${friend.totalActs} acts',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _sendCheer(friend),
                            tooltip: 'Send Cheer',
                            icon: Icon(
                              _cheeredFriends.contains(friend.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _cheeredFriends.contains(friend.id)
                                  ? AppColors.error
                                  : AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),

                const SizedBox(height: 24),

                // Encouragement Info Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: AppColors.accent),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          isOnline
                              ? 'Connected to Supabase cloud! Your streaks update automatically.'
                              : 'Private by default. Friends see completed deeds and streaks, never your personal reflections.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.accentOnSoft,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
