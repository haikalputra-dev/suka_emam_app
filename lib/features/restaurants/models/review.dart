import 'package:suka_emam_app/features/restaurants/models/restaurant.dart';

class Review {
  final String id;
  final int rating;
  final String comment;
  final String? photoUrl;
  final String? photoUrlThumbnail;
  final String createdAt;
  final UserSimple user;
  final Restaurant? restaurant;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    this.photoUrl,
    this.photoUrlThumbnail,
    required this.createdAt,
    required this.user,
    this.restaurant
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      photoUrl: json['photo_url'],
      photoUrlThumbnail: json['photo_url_thumbnail'],
      createdAt: json['created_at'],
      user: UserSimple.fromJson(json['user']),
            restaurant: json.containsKey('restaurant') 
          ? Restaurant.fromJson(json['restaurant']) 
          : null,
    );
  }
}

class UserSimple {
  final int id;
  final String? name;
  final String? avatarUrl;

  UserSimple({required this.id, required this.name, this.avatarUrl});

  factory UserSimple.fromJson(Map<String, dynamic> json) {
    return UserSimple(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
    );
  }
}
