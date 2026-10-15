import 'package:alesle_ai/core/api/generated/clients/health_api.dart';
import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/api/generated/models/readiness_dto.dart';
import 'package:alesle_ai/core/api/generated/models/readiness_dto_status.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/network/dio_factory.dart';
import 'package:alesle_ai/features/home/data/health_repository_impl.dart';
import 'package:alesle_ai/features/home/domain/server_health.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';

class _MockHealthApi extends Mock implements HealthApi {}

void main() {
  group('HealthRepositoryImpl (mocked client)', () {
    test('maps the readiness DTO to the domain', () async {
      final _MockHealthApi api = _MockHealthApi();
      when(api.healthReady).thenAnswer(
        (_) async => const ReadinessDto(
          status: ReadinessDtoStatus.ok,
          dependencies: <String, String>{'database': 'up'},
        ),
      );

      final ServerHealth health = await HealthRepositoryImpl(api).readiness();
      expect(health.dependencies, <String, String>{'database': 'up'});
      verify(api.healthReady).called(1);
    });

    test('converts client errors into Failures', () async {
      final _MockHealthApi api = _MockHealthApi();
      when(api.healthReady).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/v1/health/ready'),
          type: DioExceptionType.connectionError,
        ),
      );
      await expectLater(
        HealthRepositoryImpl(api).readiness(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  // The generated retrofit client + JSON models + error mapping, wired exactly
  // as in the app, against canned HTTP responses that mirror the backend.
  group('HealthRepositoryImpl (real client, mocked HTTP)', () {
    late Dio dio;
    late DioAdapter adapter;
    late HealthRepositoryImpl repository;

    setUp(() {
      dio = createDio(
        const AppConfig(
          environment: AppEnvironment.dev,
          distribution: Distribution.direct,
          apiBaseUrl: 'http://api.test',
        ),
      );
      adapter = DioAdapter(dio: dio);
      repository = HealthRepositoryImpl(HealthApi(dio));
    });

    test('parses a ready response', () async {
      adapter.onGet(
        '/v1/health/ready',
        (server) => server.reply(200, <String, Object?>{
          'status': 'ok',
          'dependencies': <String, String>{
            'database': 'up',
            'pgvector': 'up',
            'redis': 'up',
          },
        }),
      );
      final ServerHealth health = await repository.readiness();
      expect(health.isReady, isTrue);
    });

    test('parses the 503 error body into a ServerFailure', () async {
      adapter.onGet(
        '/v1/health/ready',
        (server) => server.reply(503, <String, Object?>{
          'error': <String, Object?>{
            'code': 'SERVICE_UNAVAILABLE',
            'message': 'One or more dependencies are unavailable',
            'details': <String, String>{'database': 'up', 'redis': 'down'},
            'requestId': 'm-0123456789abcdef01234567',
            'timestamp': '2026-10-15T12:00:00.000Z',
          },
        }),
      );
      await expectLater(
        repository.readiness(),
        throwsA(
          isA<ServerFailure>()
              .having(
                (ServerFailure f) => f.code,
                'code',
                ErrorCode.serviceUnavailable,
              )
              .having((ServerFailure f) => f.statusCode, 'status', 503),
        ),
      );
    });

    test('reports a malformed success body as UnexpectedFailure', () async {
      adapter.onGet(
        '/v1/health/ready',
        (server) => server.reply(200, <String, Object?>{'status': 'ok'}),
      );
      await expectLater(
        repository.readiness(),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });
}
