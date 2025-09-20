// lib/features/leaderboard/models/leaderboard_user.dart

class LeaderboardUser {
  final int id;
  final String name;
  final String? avatarUrl;
  final int level;
  final int periodPoints;
  final String? instagramUsername;
  final String? tiktokUsername;
  final String? facebookProfileUrl;

  LeaderboardUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.level,
    required this.periodPoints,
    this.instagramUsername,
    this.tiktokUsername,
    this.facebookProfileUrl,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      // MENGGUNAKAN .toString() lalu int.parse() agar aman
      id: int.parse(json['id'].toString()),
      name: json['name'],
      avatarUrl: json['avatar_url'],
      level: int.parse(json['level'].toString()),
      periodPoints: int.parse(json['period_points'].toString()),
      instagramUsername: json['instagram_username'],
      tiktokUsername: json['tiktok_username'],
      facebookProfileUrl: json['facebook_profile_url'],
    );
  }
}