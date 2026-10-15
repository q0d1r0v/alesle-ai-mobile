import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/network/dio_error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final RequestOptions options = RequestOptions(path: '/v1/health/ready');

  DioException ofType(DioExceptionType type) =>
      DioException(requestOptions: options, type: type);

  DioException badResponse(
    Object? data, {
    int status = 503,
    Map<String, List<String>>? headers,
  }) => DioException.badResponse(
    statusCode: status,
    requestOptions: options,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: data,
      headers: Headers.fromMap(headers ?? <String, List<String>>{}),
    ),
  );

  group('mapToFailure', () {
    test('passes a Failure through unchanged', () {
      const NetworkFailure failure = NetworkFailure();
      expect(identical(mapToFailure(failure), failure), isTrue);
    });

    test('maps every timeout and connection problem to NetworkFailure', () {
      for (final DioExceptionType type in <DioExceptionType>[
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
        DioExceptionType.connectionError,
        DioExceptionType.badCertificate,
      ]) {
        expect(
          mapToFailure(ofType(type)),
          isA<NetworkFailure>(),
          reason: type.name,
        );
      }
    });

    test('reads code and request id from the standard error body', () {
      final Failure failure = mapToFailure(
        badResponse(<String, Object?>{
          'error': <String, Object?>{
            'code': 'SERVICE_UNAVAILABLE',
            'message': 'One or more dependencies are unavailable',
            'requestId': 'req-12345678',
            'timestamp': '2026-10-15T12:00:00.000Z',
            'details': <String, String>{'redis': 'down'},
          },
        }),
      );
      expect(
        failure,
        isA<ServerFailure>()
            .having(
              (ServerFailure f) => f.code,
              'code',
              ErrorCode.serviceUnavailable,
            )
            .having((ServerFailure f) => f.statusCode, 'status', 503)
            .having(
              (ServerFailure f) => f.requestId,
              'requestId',
              'req-12345678',
            ),
      );
    });

    test(
      'keeps working when the server adds a code this build does not know',
      () {
        final Failure failure = mapToFailure(
          badResponse(<String, Object?>{
            'error': <String, Object?>{
              'code': 'BRAND_NEW_CODE',
              'message': 'x',
              'requestId': 'req-12345678',
              'timestamp': '2026-10-15T12:00:00.000Z',
            },
          }),
        );
        expect((failure as ServerFailure).code, ErrorCode.$unknown);
      },
    );

    test('falls back to the header request id for a non-standard body', () {
      final Failure failure = mapToFailure(
        badResponse(
          '<html>502 Bad Gateway</html>',
          status: 502,
          headers: <String, List<String>>{
            requestIdHeader: <String>['proxy-id-0001'],
          },
        ),
      );
      expect(
        failure,
        isA<ServerFailure>()
            .having((ServerFailure f) => f.code, 'code', ErrorCode.$unknown)
            .having((ServerFailure f) => f.statusCode, 'status', 502)
            .having(
              (ServerFailure f) => f.requestId,
              'requestId',
              'proxy-id-0001',
            ),
      );
    });

    test('treats a JSON object of the wrong shape as unknown', () {
      final Failure failure = mapToFailure(
        badResponse(<String, Object?>{'message': 'nope'}),
      );
      expect((failure as ServerFailure).code, ErrorCode.$unknown);
    });

    test('maps cancel/unknown and foreign errors to UnexpectedFailure', () {
      expect(
        mapToFailure(ofType(DioExceptionType.cancel)),
        isA<UnexpectedFailure>(),
      );
      expect(
        mapToFailure(ofType(DioExceptionType.unknown)),
        isA<UnexpectedFailure>(),
      );
      final Failure foreign = mapToFailure(const FormatException('bad'));
      expect(foreign, isA<UnexpectedFailure>());
      expect((foreign as UnexpectedFailure).cause, isA<FormatException>());
    });
  });

  group('Failure.toString', () {
    test('is informative for logs', () {
      expect(const NetworkFailure().toString(), 'NetworkFailure');
      expect(
        const ServerFailure(
          code: ErrorCode.notFound,
          statusCode: 404,
          requestId: 'r',
        ).toString(),
        'ServerFailure(code: NOT_FOUND, status: 404, requestId: r)',
      );
      expect(
        const ServerFailure(
          code: ErrorCode.$unknown,
          statusCode: null,
        ).toString(),
        contains('code: unknown'),
      );
      expect(const UnexpectedFailure('x').toString(), 'UnexpectedFailure(x)');
    });
  });
}
