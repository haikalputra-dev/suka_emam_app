import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../env.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 50),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Interceptor ini akan otomatis menambahkan token ke SEMUA request
          final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

  static Dio get i => _dio;

  static Future<Response<dynamic>> checkin({
      required String qr,
      required double lat,
      required double lng,
      double? accuracy,
    }) {
      return _dio.post('/checkin', data: {
        'qr': qr,
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
      });
    }

  /// [METODE BARU] Mengirim Firebase ID Token ke backend untuk sinkronisasi.
  static Future<void> syncUser(String firebaseToken) async {
    try {
      await _dio.post(
        '/auth/sync', // Endpoint di Laravel untuk sinkronisasi
        options: Options(
          headers: {
            // Kirim token ini secara spesifik untuk endpoint sync
            'Authorization': 'Bearer $firebaseToken',
          },
        ),
      );
    } on DioException catch (e) {
      // Buat pesan error lebih mudah dibaca
      final errorMessage = e.response?.data['message'] ?? 'Gagal sinkronisasi pengguna.';
      throw Exception(errorMessage);
    }
  }
}
