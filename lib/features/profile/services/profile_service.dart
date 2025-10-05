// lib/features/profile/services/profile_service.dart

import 'package:dio/dio.dart';
import 'package:suka_emam_app/core/dio_client.dart';
import 'package:suka_emam_app/features/profile/models/point_history_item.dart';
import 'package:suka_emam_app/features/profile/models/checkin_history_item.dart';
import 'package:suka_emam_app/features/restaurants/models/review.dart';
import '../models/user_profile.dart';

class ProfileService {
  final Dio _dio = DioClient.i;

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/me');

      // --- LANGKAH DEBUGGING: Print respons mentah dari server ---
      print('===== RAW RESPONSE FROM /api/me =====');
      print(response.data);
      print('=======================================');
      // -----------------------------------------------------------
      
      return UserProfile.fromJson(response.data['data']);

    } on DioException catch (e) {
      // Tangani error API
      print('Error fetching profile: ${e.response?.data ?? e.message}');
      throw Exception('Gagal memuat data profil.');
    } catch (e) {
      // Tangani error parsing atau lainnya
      print('Unexpected error in getProfile (kemungkinan saat parsing): $e');
      throw Exception('Terjadi kesalahan tidak terduga.');
    }
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/me', // Endpoint yang baru kita buat
        data: data, // Kirim data form sebagai body request
      );

      if (response.statusCode == 200) {
        // Kembalikan data user yang sudah diperbarui
        return UserProfile.fromJson(response.data['data']);
      } else {
        throw Exception('Gagal memperbarui profil');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }

    Future<List<CheckinHistoryItem>> getCheckinHistory() async {
    try {
      final response = await _dio.get('/me/checkins');
      if (response.statusCode == 200 && response.data['data'] is List) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => CheckinHistoryItem.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat riwayat check-in.');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? 'Gagal memuat riwayat.'}');
    }
  }

    Future<List<PointHistoryItem>> getPointHistory() async {
    try {
      final response = await _dio.get('/me/point-history'); // <-- Ganti endpoint
      if (response.statusCode == 200 && response.data['data'] is List) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => PointHistoryItem.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat riwayat poin.');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? 'Gagal memuat riwayat.'}');
    }
  }

    Future<List<Review>> getReviewHistory() async {
    try {
      final response = await _dio.get('/me/reviews');
      print("======RAWWWWW==========");
      print(response);
      if (response.statusCode == 200 && response.data['data'] is List) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat riwayat ulasan.');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? 'Gagal memuat riwayat.'}');
    }
  }
}