// lib/features/profile/models/user_profile.dart

// Dihapus: Kelas CheckinHistory dan LevelProgress tidak lagi di endpoint utama.
// Tujuan: Membuat profil lebih cepat dimuat. Riwayat check-in bisa dimuat di halaman lain.

// Ditambahkan: Kelas baru untuk merepresentasikan sebuah Badge.
class Badge {
  final int id;
  final String name;
  final String description;
  final String imageUrl;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Badge',
      description: json['description'] ?? '',
      imageUrl: (json['image_url'] as String?)?.trim() ?? '',
    );
  }

    factory Badge.empty() {
    return Badge(
      id: 0,
      name: '',
      description: '',
      imageUrl: '',
    );
  }
}

// Diperbarui: Kelas utama UserProfile disesuaikan dengan data baru dari API.
class UserProfile {
  final String name;
  final String email;
  final String? avatarUrl; // Menggunakan 'avatarUrl' agar lebih deskriptif
  final int totalPoints;
  final int totalReviews;
  final int totalBadges;
  final int level;
  final List<Badge> badges;

  UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.totalPoints,
    required this.totalReviews,
    required this.totalBadges,
    required this.level,
    required this.badges,
  });

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Diperbarui: Logika parsing JSON disesuaikan dengan struktur API terbaru.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var badgeList = (json['badges'] as List?)
            ?.map((item) => Badge.fromJson(item))
            .toList() ??
        [];

    return UserProfile(
      name: json['name'] ?? 'Pengguna SukaEmam',
      email: json['email'] ?? 'Tidak ada email',
      avatarUrl: json['avatar_url'],
      
      // Gunakan helper _parseInt untuk semua field angka
      totalPoints: _parseInt(json['total_points']),
      totalReviews: _parseInt(json['total_reviews']),
      totalBadges: _parseInt(json['total_badges']),
      level: _parseInt(json['level']),
      
      badges: badgeList,
    );
  }
}
