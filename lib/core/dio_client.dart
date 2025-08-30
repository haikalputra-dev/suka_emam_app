import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../env.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await FirebaseAuth.instance.currentUser?.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

  static Dio get i => _dio;

    Future<Response<dynamic>> checkin({
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
