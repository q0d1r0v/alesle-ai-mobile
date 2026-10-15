import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'request_id_interceptor.dart';

/// The one Dio instance configuration the app uses.
Dio createDio(AppConfig config) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: <String, Object>{'Accept': 'application/json'},
    ),
  );
  dio.interceptors
    ..add(RequestIdInterceptor())
    ..add(AuthInterceptor(() => config.devAuthToken));
  return dio;
}
