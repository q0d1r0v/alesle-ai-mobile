import 'package:dio/dio.dart';

import '../auth/access_token_source.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'request_id_interceptor.dart';

/// The one Dio instance configuration the app uses. With [tokens], requests
/// carry the signed-in user's bearer token; without, they go anonymous (the
/// refresh call itself, health checks).
Dio createDio(AppConfig config, {AccessTokenSource? tokens}) {
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
  dio.interceptors.add(RequestIdInterceptor());
  if (tokens != null) dio.interceptors.add(AuthInterceptor(tokens, dio));
  return dio;
}
