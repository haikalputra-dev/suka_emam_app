import 'package:suka_emam_app/features/restaurants/models/restaurant.dart';

class CheckinHistoryItem {
  final String id;
  final int pointsEarned;
  final String checkinTime;
  final Restaurant restaurant;

  CheckinHistoryItem({
    required this.id,
    required this.pointsEarned,
    required this.checkinTime,
    required this.restaurant,
  });

  factory CheckinHistoryItem.fromJson(Map<String, dynamic> json) {
    return CheckinHistoryItem(
      id: json['id'],
      pointsEarned: json['points_earned'],
      checkinTime: json['checkin_time'],
      restaurant: Restaurant.fromJson(json['restaurant']),
    );
  }
}
