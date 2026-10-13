class FriendModel {
  const FriendModel({
    required this.id,
    required this.name,
    required this.streak,
    required this.totalActs,
    required this.avatarUrl,
    required this.lastActive,
  });

  final String id;
  final String name;
  final int streak;
  final int totalActs;
  final String? avatarUrl;
  final String lastActive;

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] as String,
      name: (json['full_name'] as String?)?.trim().isNotEmpty == true
          ? json['full_name'] as String
          : 'Kind Friend',
      streak: (json['current_streak'] as int?) ?? 0,
      totalActs: (json['total_kind_acts'] as int?) ?? 0,
      avatarUrl: json['avatar_url'] as String?,
      lastActive: json['updated_at'] != null ? 'Today' : 'Recently',
    );
  }
}
