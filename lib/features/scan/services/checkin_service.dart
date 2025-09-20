// lib/features/scan/services/checkin_service.dart

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suka_emam_app/core/dio_client.dart';
import '../models/checkin_response.dart';

class CheckinService {
  final Dio _dio = DioClient.i;

  // Method untuk melakukan check-in
  Future<CheckinSuccessResponse> performCheckin({
    required String qrCode,
    required Position position,
    // required String restaurantName,
  }) async {
    try {
      final response = await _dio.post(
        '/checkin',
        data: {
          'qr': qrCode,
          'lat': position.latitude,
          'lng': position.longitude,
          'accuracy': position.accuracy,
        },
      );
      return CheckinSuccessResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Gagal melakukan check-in.';
      throw Exception(errorMessage);
    }
  }

  // Method untuk mengirim review yang terikat pada check-in
  Future<ReviewSuccessResponse> submitReviewForCheckin({
    required String checkinId,
    required int rating,
    required String comment,
  }) async {
    try {
      // Panggil endpoint baru
      final response = await _dio.post(
        '/checkins/$checkinId/review',
        data: {
          'rating': rating,
          'comment': comment,
        },
      );
      return ReviewSuccessResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Gagal mengirim review.';
      throw Exception(errorMessage);
    }
  }
}