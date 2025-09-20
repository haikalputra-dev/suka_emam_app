// lib/features/leaderboard/services/leaderboard_service.dart

import 'package:dio/dio.dart';
import 'package:suka_emam_app/core/dio_client.dart'; // Sesuaikan dengan path Dio Client Anda
import 'package:suka_emam_app/features/leaderboard/models/leaderboard_user.dart';

class LeaderboardService {
  final Dio _dio = DioClient.i; // Menggunakan instance Dio terpusat

  Future<List<LeaderboardUser>> getLeaderboard({String period = 'weekly'}) async {
    try {
      final response = await _dio.get(
        '/leaderboard',
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => LeaderboardUser.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } on DioException catch (e) {
      // Menangani error dari Dio
      throw Exception('Failed to load leaderboard: ${e.message}');
    }
  }
}