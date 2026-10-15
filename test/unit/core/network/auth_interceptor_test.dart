import 'package:alesle_ai/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  Dio dioWith(String? token) {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test'));
    dio.interceptors.add(AuthInterceptor(() => token));
    DioAdapter(dio: dio).onGet('/x', (server) => server.reply(200, null));
    return dio;
  }

  test('adds the bearer token', () async {
    final Response<Object?> response = await dioWith('tok').get<Object?>('/x');
    expect(response.requestOptions.headers['Authorization'], 'Bearer tok');
  });

  test('no token, no header', () async {
    final Response<Object?> response = await dioWith(null).get<Object?>('/x');
    expect(
      response.requestOptions.headers.containsKey('Authorization'),
      isFalse,
    );
  });

  test('keeps an Authorization header set by the caller', () async {
    final Response<Object?> response = await dioWith('tok').get<Object?>(
      '/x',
      options: Options(
        headers: <String, Object>{'Authorization': 'Bearer own'},
      ),
    );
    expect(response.requestOptions.headers['Authorization'], 'Bearer own');
  });
}
