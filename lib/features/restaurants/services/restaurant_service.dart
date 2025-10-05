import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart'; // Impor Position
import '../models/restaurant.dart';
import '../models/review.dart'; // <-- Import model Review
import '../../../core/dio_client.dart';

class RestaurantService {
  final Dio _dio = DioClient.i;

  // Update method untuk menerima kedua parameter: Position dan sortBy
  Future<List<Restaurant>> getRestaurants({
    Position? userPosition,
    String? sortBy,
  }) async {
    try {
      // Siapkan query parameter
      Map<String, dynamic> queryParams = {};
      
      // Tambahkan koordinat jika ada
      if (userPosition != null) {
        queryParams['lat'] = userPosition.latitude;
        queryParams['lng'] = userPosition.longitude;
      }
      
      // Tambahkan filter sortBy jika diminta
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }
      
      // Kirim request dengan query parameter
      final response = await _dio.get('/restaurants', queryParameters: queryParams);

      final responseBody = response.data;
      List<dynamic> restaurantData;

      if (responseBody is Map<String, dynamic> && responseBody.containsKey('data')) {
        restaurantData = responseBody['data'];
      } else {
        throw Exception('Format respons API tidak valid');
      }

      List<Restaurant> restaurants = restaurantData.map((json) => Restaurant.fromJson(json)).toList();
      
      return restaurants;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Gagal memuat restoran. Periksa koneksi internet Anda.';
      throw Exception(errorMessage);
    }
  }

  /// [METODE BARU] Mengambil daftar review untuk sebuah restoran.
  Future<List<Review>> getReviewsForRestaurant(int restaurantId) async {
    try {
      final response = await _dio.get('/restaurants/$restaurantId/reviews');

      if (response.statusCode == 200 && response.data['data'] is List) {
        List<dynamic> reviewData = response.data['data'];
        return reviewData.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat review.');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data?['message'] ?? 'Gagal memuat review.'}');
    }
  }

  Future<void> submitReview({
    required int restaurantId,
    required int rating,
    required String comment,
    // Tambahkan parameter untuk foto jika perlu
  }) async {
    try {
      await _dio.post(
        '/restaurants/$restaurantId/reviews',
        data: {
          'rating': rating,
          'comment': comment,
        },
      );
    } on DioException catch (e) {
      // Buat pesan error lebih mudah dibaca
      final errorMessage = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan.';
      throw Exception(errorMessage);
    }
  }
}

