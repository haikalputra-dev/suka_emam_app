// lib/features/restaurants/services/restaurant_service.dart
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart'; // Impor Position
import '../models/restaurant.dart';
import '../../../core/dio_client.dart';

class RestaurantService {
  final Dio _dio = DioClient.i;

  // Update method untuk menerima kedua parameter: Position dan onlyRecommended
  Future<List<Restaurant>> getRestaurants({
    Position? userPosition,
    bool onlyRecommended = false,
  }) async {
    try {
      // Siapkan query parameter
      Map<String, dynamic> queryParams = {};
      
      // Tambahkan koordinat jika ada
      if (userPosition != null) {
        queryParams['lat'] = userPosition.latitude;
        queryParams['lng'] = userPosition.longitude;
      }
      
      // Tambahkan filter recommended jika diminta
      if (onlyRecommended) {
        queryParams['recommended'] = '1';
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
      
      // Jika API tidak mendukung filter recommended, lakukan filter di client-side
      if (onlyRecommended && !queryParams.containsKey('recommended')) {
        restaurants = restaurants.where((restaurant) => restaurant.isRecommended == true).toList();
      }
      
      return restaurants;
    } on DioException catch (e) {
      print('Error fetching restaurants: $e');
      throw Exception('Gagal memuat restoran.');
    }
  }

  // Method khusus untuk mendapatkan restoran recommended (opsional)
  Future<List<Restaurant>> getRecommendedRestaurants({Position? userPosition}) async {
    return getRestaurants(userPosition: userPosition, onlyRecommended: true);
  }

  // Method khusus untuk mendapatkan semua restoran (opsional)
  Future<List<Restaurant>> getAllRestaurants({Position? userPosition}) async {
    return getRestaurants(userPosition: userPosition, onlyRecommended: false);
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