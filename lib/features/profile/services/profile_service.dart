// lib/features/profile/services/profile_service.dart

import 'package:dio/dio.dart';
import 'package:suka_emam_app/core/dio_client.dart';
import '../models/user_profile.dart';

class ProfileService {
  final Dio _dio = DioClient.i;

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/me'); // Panggil endpoint /api/me
      return UserProfile.fromJson(response.data['data']);
    } on DioException catch (e) {
      // Tangani error API
      print('Error fetching profile: $e');
      throw Exception('Gagal memuat data profil.');
    } catch (e) {
      // Tangani error parsing atau lainnya
      print('Unexpected error in getProfile: $e');
      throw Exception('Terjadi kesalahan tidak terduga.');
    }
  }
}