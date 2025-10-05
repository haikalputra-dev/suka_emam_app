// lib/features/scan/services/checkin_service.dart

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suka_emam_app/core/dio_client.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> submitReviewForCheckin({
    required String checkinId,
    required int rating,
    required String comment,
    XFile? photo, // Tambahkan parameter XFile yang bisa null
  }) async {
    try {
      // Siapkan data form
      final formData = FormData.fromMap({
        'rating': rating,
        'comment': comment,
      });

      // Jika ada foto yang dipilih, tambahkan ke form data
      if (photo != null) {
        formData.files.add(MapEntry(
          'photo',
          await MultipartFile.fromFile(photo.path, filename: photo.name),
        ));
      }

      // Kirim request dengan FormData
      await _dio.post(
        '/checkins/$checkinId/review',
        data: formData,
      );
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Gagal mengirim review.';
      throw Exception(errorMessage);
    }
  }
}