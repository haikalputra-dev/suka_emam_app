// lib/features/profile/models/user_profile.dart

// Kelas untuk menampung riwayat check-in
class CheckinHistory {
  final int id;
  final String restaurantName;
  final int pointsEarned;
  final String checkedInAt;

  CheckinHistory({
    required this.id,
    required this.restaurantName,
    required this.pointsEarned,
    required this.checkedInAt,
  });

  factory CheckinHistory.fromJson(Map<String, dynamic> json) {
    return CheckinHistory(
      id: json['id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? 'Nama Restoran Tidak Ditemukan',
      pointsEarned: json['points_earned'] ?? 0,
      checkedInAt: json['checked_in_at'] ?? '-',
    );
  }
}

// Kelas untuk menampung data progres level
class LevelProgress {
  final int currentXp;
  final int xpForNextLevel;
  final double progressPercentage;

  LevelProgress({
    required this.currentXp,
    required this.xpForNextLevel,
    required this.progressPercentage,
  });

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      currentXp: json['current_xp'] ?? 0,
      xpForNextLevel: json['xp_for_next_level'] ?? 100,
      // Pastikan percentage adalah double antara 0.0 dan 100.0
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Kelas utama untuk profil pengguna
class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final int totalPoints;
  final int level;
  final LevelProgress levelProgress;
  final List<CheckinHistory> checkinHistory;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.totalPoints,
    required this.level,
    required this.levelProgress,
    required this.checkinHistory,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Ambil daftar riwayat check-in dan ubah menjadi List<CheckinHistory>
    var historyList = (json['checkin_history'] as List?)
        ?.map((item) => CheckinHistory.fromJson(item))
        .toList() ?? [];

    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'User',
      email: json['email'] ?? '-',
      avatar: json['avatar'],
      totalPoints: json['total_points'] ?? 0,
      level: json['level'] ?? 1,
      levelProgress: LevelProgress.fromJson(json['level_progress'] ?? {}),
      checkinHistory: historyList,
    );
  }
}