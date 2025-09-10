// lib/features/restaurants/models/restaurant.dart

class Restaurant {
  final int id;
  final String name;
  final String shortAddress;
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
    required this.shortAddress,
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
      // Sediakan nilai default jika data null atau tidak ada
    final List<dynamic> galleryImagesData = json['galleryImageUrls'] ?? [];
    final Map<String, dynamic> locationData = json['location'] ?? {};

    final imageUrl = (json['mainImageUrl'] as String?)?.trim();
   
    return Restaurant(
      id: json['id'],
      name: json['name'] ?? 'Nama Tidak Tersedia',
      shortAddress: json['short_address'] ?? 'Alamat Tidak Tersedia',
      description: json['description'] ?? '-',
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      priceInfo: json['price_info'] ?? '-',
      mainImageUrl: (imageUrl == null || imageUrl.isEmpty)
        ? 'https://placehold.co/300x200?text=No%20Image\nAvailable'
        : imageUrl,
      // galleryImageUrls: List<String>.from(json['gallery_image_urls'] ?? []),
      galleryImageUrls: List<String>.from(galleryImagesData),
      isRecommended: json['is_recommended'] ?? false,
      latitude: (locationData['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (locationData['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}