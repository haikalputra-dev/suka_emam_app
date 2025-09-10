// lib/features/restaurants/services/restaurant_service.dart
import 'package:dio/dio.dart';
import '../models/restaurant.dart';
import '../../../core/dio_client.dart'; // Impor Dio client yang sudah ada
import 'dart:convert';

class RestaurantService {
  final Dio _dio = DioClient.i; // Gunakan instance Dio terpusat

  // Method untuk mengambil semua restoran
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await _dio.get('/restaurants'); // Panggil endpoint /api/restaurants

          print('TIPE DATA RESPONS: ${response.data.runtimeType}');
          print('ISI RAW RESPONS: ${jsonEncode(response.data)}');

      // API Laravel biasanya membungkus data dalam key 'data'
      List<dynamic> restaurantData = response.data['data'];

      // Ubah setiap item JSON menjadi objek Restaurant
      return restaurantData.map((json) => Restaurant.fromJson(json)).toList();

    } on DioException catch (e) {
      // Tangani error (misal: koneksi gagal, server error)
      print('Error fetching restaurants: $e');
      // Kembalikan list kosong atau lempar exception custom
      throw Exception('Failed to load restaurants');
    }
  }
}