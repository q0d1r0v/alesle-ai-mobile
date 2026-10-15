import 'dart:math';

import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/network/dio_error_mapper.dart';
import 'package:alesle_ai/core/network/dio_factory.dart';
import 'package:alesle_ai/core/network/request_id_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('RequestIdInterceptor', () {
    test('ids match the format the backend echoes', () {
      final RequestIdInterceptor interceptor = RequestIdInterceptor(
        random: Random(1),
      );
      final String id = interceptor.nextId();
      expect(id, matches(RegExp(r'^m-[0-9a-f]{24}$')));
      expect(RegExp(r'^[A-Za-z0-9._-]{8,128}$').hasMatch(id), isTrue);
      expect(interceptor.nextId(), isNot(id));
    });
  });

  group('createDio', () {
    const AppConfig config = AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'http://api.test',
    );

    test(
      'targets the configured origin and tags requests with an id',
      () async {
        final Dio dio = createDio(config);
        final DioAdapter adapter = DioAdapter(dio: dio);
        adapter.onGet(
          '/v1/health/live',
          (server) => server.reply(200, <String, Object?>{}),
        );

        final Response<Object?> response = await dio.get<Object?>(
          '/v1/health/live',
        );

        expect(
          response.requestOptions.uri.toString(),
          'http://api.test/v1/health/live',
        );
        expect(
          response.requestOptions.headers[requestIdHeader],
          matches(RegExp(r'^m-[0-9a-f]{24}$')),
        );
        expect(dio.options.connectTimeout, const Duration(seconds: 10));
      },
    );

    test('keeps a request id set by the caller', () async {
      final Dio dio = createDio(config);
      DioAdapter(dio: dio).onGet('/x', (server) => server.reply(200, null));

      final Response<Object?> response = await dio.get<Object?>(
        '/x',
        options: Options(
          headers: <String, Object>{requestIdHeader: 'caller-chosen-id'},
        ),
      );
      expect(
        response.requestOptions.headers[requestIdHeader],
        'caller-chosen-id',
      );
    });
  });
}
