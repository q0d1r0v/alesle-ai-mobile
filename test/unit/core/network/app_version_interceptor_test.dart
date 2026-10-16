import 'package:alesle_ai/core/config/app_build.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/network/app_version_interceptor.dart';
import 'package:alesle_ai/core/network/dio_factory.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  const AppConfig config = AppConfig(
    environment: AppEnvironment.dev,
    apiBaseUrl: 'http://api.test',
  );
  const AppBuild build = AppBuild(
    versionCode: 7,
    versionName: '0.7.0',
    certSha256: '',
  );

  test('names this build on every request', () async {
    final Dio dio = createDio(config, build: build);
    DioAdapter(dio: dio).onGet('/x', (server) => server.reply(200, null));
    final Response<Object?> response = await dio.get<Object?>('/x');
    expect(response.requestOptions.headers[appVersionHeader], '7');
  });

  test('an unknown build sends no version', () async {
    final Dio dio = createDio(config);
    DioAdapter(dio: dio).onGet('/x', (server) => server.reply(200, null));
    final Response<Object?> response = await dio.get<Object?>('/x');
    expect(response.requestOptions.headers[appVersionHeader], isNull);
    expect(AppBuild.unknown.known, isFalse);
    expect(build.known, isTrue);
  });

  test('a 426 answer asks for the update; other errors do not', () async {
    int asked = 0;
    final Dio dio = createDio(
      config,
      build: build,
      onUpgradeRequired: () => asked++,
    );
    DioAdapter(dio: dio)
      ..onGet('/old', (server) => server.reply(426, <String, Object?>{}))
      ..onGet('/broken', (server) => server.reply(500, <String, Object?>{}));
    await expectLater(dio.get<Object?>('/old'), throwsA(isA<DioException>()));
    expect(asked, 1);
    await expectLater(
      dio.get<Object?>('/broken'),
      throwsA(isA<DioException>()),
    );
    expect(asked, 1);
  });

  test('works without a callback', () async {
    final Dio dio = createDio(config, build: build);
    DioAdapter(dio: dio)
        .onGet('/old', (server) => server.reply(426, <String, Object?>{}));
    await expectLater(dio.get<Object?>('/old'), throwsA(isA<DioException>()));
  });
}
