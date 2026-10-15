import 'package:dio/dio.dart';

/// Adds the bearer token to every request. Until accounts exist (Sprint 5)
/// the token is the dev build's development token; release builds have none.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._token);

  final String? Function() _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = _token();
    if (token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
