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

}
