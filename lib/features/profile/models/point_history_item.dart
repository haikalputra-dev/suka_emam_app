class PointHistoryItem {
  final int id;
  final int points;
  final String description;
  final String createdAt;

  PointHistoryItem({
    required this.id,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory PointHistoryItem.fromJson(Map<String, dynamic> json) {
    return PointHistoryItem(
      id: json['id'],
      points: json['points'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }
}
