import 'package:dio/dio.dart';

import '../auth/access_token_source.dart';

/// Adds the bearer token and, when the server refuses it (expired early,
/// rotated elsewhere), refreshes once and retries the request.
///
/// Not a QueuedInterceptor: a retry that fails again would wait in the queue
/// behind the handler waiting for it (deadlock). Concurrent refreshes are
/// already collapsed into one by the token source.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens, this._dio);

  final AccessTokenSource _tokens;

  /// Sends the retry; the same Dio, so the retry is intercepted too.
  final Dio _dio;

  static const String _retried = 'auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey('Authorization')) {
      try {
        final String? token = await _tokens.accessToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
      } on Object catch (error) {
        // Offline while refreshing: send without a token and let the call fail.
        options.extra['auth_error'] = error.runtimeType.toString();
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final DioException error = err;
    final RequestOptions request = error.requestOptions;
    final bool refused = error.response?.statusCode == 401;
    if (!refused || request.extra[_retried] == true) {
      handler.next(error);
      return;
    }
    final String? sent = request.headers['Authorization'] as String?;
    if (sent == null) {
      handler.next(error);
      return;
    }
    try {
      final String? fresh = await _tokens.accessToken(forceRefresh: true);
      if (fresh == null) {
        handler.next(error);
        return;
      }
      final Response<Object?> retried = await _dio.fetch<Object?>(
        request.copyWith(
          headers: <String, Object?>{
            ...request.headers,
            'Authorization': 'Bearer $fresh',
          },
          extra: <String, Object?>{...request.extra, _retried: true},
        ),
      );
      handler.resolve(retried);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } on Object {
      handler.next(error);
    }
  }
}
