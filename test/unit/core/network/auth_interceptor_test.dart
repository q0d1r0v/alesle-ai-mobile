import 'package:alesle_ai/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

/// Answers 401 to [refused] tokens and 200 otherwise, recording what it saw.
final class _Server implements HttpClientAdapter {
  _Server(this.refused);

  final Set<String> refused;
  final List<String?> seen = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String? auth = options.headers['Authorization'] as String?;
    seen.add(auth);
    final bool ok = auth == null || !refused.contains(auth);
    return ResponseBody.fromString(
      ok ? '{}' : '{"error":{"code":"UNAUTHENTICATED","message":"x"}}',
      ok ? 200 : 401,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  (Dio, _Server) dioWith(
    FakeTokens tokens, {
    Set<String> refused = const <String>{},
  }) {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test'));
    final _Server server = _Server(refused);
    dio
      ..httpClientAdapter = server
      ..interceptors.add(AuthInterceptor(tokens, dio));
    return (dio, server);
  }

  test('adds the bearer token', () async {
    final (Dio dio, _Server server) = dioWith(FakeTokens('tok'));
    await dio.get<Object?>('/x');
    expect(server.seen, <String?>['Bearer tok']);
  });

  test('signed out: no header', () async {
    final (Dio dio, _Server server) = dioWith(FakeTokens(null));
    await dio.get<Object?>('/x');
    expect(server.seen, <String?>[null]);
  });

  test('keeps an Authorization header set by the caller', () async {
    final (Dio dio, _Server server) = dioWith(FakeTokens('tok'));
    await dio.get<Object?>(
      '/x',
      options: Options(
        headers: <String, Object>{'Authorization': 'Bearer own'},
      ),
    );
    expect(server.seen, <String?>['Bearer own']);
  });

  test('a refused token is refreshed once and the request retried', () async {
    final FakeTokens tokens = FakeTokens('old')..refreshesTo = 'new';
    final (Dio dio, _Server server) = dioWith(
      tokens,
      refused: <String>{'Bearer old'},
    );
    final Response<Object?> response = await dio.get<Object?>('/x');
    expect(response.statusCode, 200);
    expect(server.seen, <String?>['Bearer old', 'Bearer new']);
    expect(tokens.forced, 1);
  });

  test(
    'gives up when the refresh signs the user out, or is refused again',
    () async {
      final FakeTokens signedOut = FakeTokens('old');
      final (Dio dio, _) = dioWith(signedOut, refused: <String>{'Bearer old'});
      await expectLater(dio.get<Object?>('/x'), throwsA(isA<DioException>()));

      final FakeTokens stubborn = FakeTokens('bad')..refreshesTo = 'bad';
      final (Dio again, _Server server) = dioWith(
        stubborn,
        refused: <String>{'Bearer bad'},
      );
      await expectLater(again.get<Object?>('/x'), throwsA(isA<DioException>()));
      // One retry, never a loop.
      expect(server.seen, <String?>['Bearer bad', 'Bearer bad']);
    },
  );

  test('an anonymous request that is refused is not retried', () async {
    final FakeTokens tokens = FakeTokens(null);
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test'));
    final _Server server = _Server(<String>{});
    dio
      ..httpClientAdapter = _Refusing()
      ..interceptors.add(AuthInterceptor(tokens, dio));
    await expectLater(dio.get<Object?>('/x'), throwsA(isA<DioException>()));
    expect(tokens.forced, 0);
    expect(server.seen, isEmpty);
  });
}

final class _Refusing implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString('{}', 401);

  @override
  void close({bool force = false}) {}
}
