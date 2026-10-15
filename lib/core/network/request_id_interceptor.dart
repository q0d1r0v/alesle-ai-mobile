import 'dart:math';

import 'package:dio/dio.dart';

import 'dio_error_mapper.dart';

/// Tags every request with an `X-Request-Id` so a support ticket can be
/// matched to the server's log line. The backend echoes ids that match
/// `[A-Za-z0-9._-]{8,128}`; ours are `m-` + 24 hex characters.
final class RequestIdInterceptor extends Interceptor {
  RequestIdInterceptor({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(requestIdHeader, nextId);
    handler.next(options);
  }

  String nextId() {
    final StringBuffer buffer = StringBuffer('m-');
    for (int i = 0; i < 12; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
