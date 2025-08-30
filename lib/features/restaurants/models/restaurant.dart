// lib/features/restaurants/models/restaurant.dart

class Restaurant {
  final int id;
  final String name;
  final List<String> categories;
  final String shortAddress;
  final String fullAddress;
  final String description;
  final double rating;
  final int reviewCount;
  final String priceInfo;
  final String mainImageUrl;
  final List<String> galleryImageUrls;
  final bool isRecommended;
  final double latitude;
  final double longitude;

  Restaurant({
    required this.id,
    required this.name,
    required this.categories,
    required this.shortAddress,
    required this.fullAddress,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.priceInfo,
    required this.mainImageUrl,
    required this.galleryImageUrls,
    required this.isRecommended,
    required this.latitude,
    required this.longitude,
  });

  // Factory constructor untuk membuat instance Restaurant dari JSON
  // Ini akan sangat berguna saat kita konek ke API asli
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      categories: List<String>.from(json['categories']),
      shortAddress: json['short_address'],
      fullAddress: json['full_address'],
      description: json['description'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'],
      priceInfo: json['price_info'],
      mainImageUrl: json['main_image_url'],
      galleryImageUrls: List<String>.from(json['gallery_image_urls']),
      isRecommended: json['is_recommended'] ?? false,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}