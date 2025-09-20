
// Model untuk menampung data saat check-in berhasil
class CheckinSuccessResponse {
  final String checkinId;
  final int restaurantId;
  final String restaurantName;
  final int pointsEarned;
  final int totalPoints;
  final bool levelUp;
  final int currentLevel;

  CheckinSuccessResponse({
    required this.checkinId,
    required this.restaurantId,
    required this.restaurantName, // Kita butuh nama resto untuk ditampilkan
    required this.pointsEarned,
    required this.totalPoints,
    required this.levelUp,
    required this.currentLevel,
  });

  factory CheckinSuccessResponse.fromJson(Map<String, dynamic> json) {
    return CheckinSuccessResponse(
      // Asumsi 'checkin_id' adalah UUID (string) dari API
      checkinId: json['checkin_id'], 
      restaurantId: json['restaurant_id'], // Kita akan butuh ini
      restaurantName: json['restaurant_name'] ?? 'Restoran Tidak Ditemukan',
      pointsEarned: json['points_earned'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      levelUp: json['level_up'] ?? false,
      currentLevel: json['current_level'] ?? 1,
    );
  }
}

// Model untuk menampung data saat review berhasil
class ReviewSuccessResponse {
  final String message;
  final int pointsEarned;

  ReviewSuccessResponse({
    required this.message,
    required this.pointsEarned,
  });

  factory ReviewSuccessResponse.fromJson(Map<String, dynamic> json) {
    return ReviewSuccessResponse(
      message: json['message'] ?? 'Berhasil!',
      pointsEarned: json['points_earned'] ?? 0,
    );
  }
}