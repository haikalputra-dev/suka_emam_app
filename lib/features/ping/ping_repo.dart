import 'package:dio/dio.dart';
import '../../core/dio_client.dart';

class PingRepo {
  final Dio _dio = DioClient.i;

  Future<String> ping() async {
    final res = await _dio.get('/ping');
    return res.data.toString();
  }
}
