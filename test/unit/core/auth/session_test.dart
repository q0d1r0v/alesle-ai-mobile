import 'dart:async';

import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/api/generated/models/token_pair_dto.dart';
import 'package:alesle_ai/core/auth/api_token_refresher.dart';
import 'package:alesle_ai/core/auth/auth_session.dart';
import 'package:alesle_ai/core/auth/session_controller.dart';
import 'package:alesle_ai/core/auth/session_store.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final DateTime now = DateTime.utc(2026, 10, 16, 12);

  group('AuthSession', () {
    test('round-trips through its stored form', () {
      final AuthSession session = testSession(now: now);
      final AuthSession? back = AuthSession.decode(session.encode());
      expect(back?.accessToken, session.accessToken);
      expect(back?.refreshToken, session.refreshToken);
      expect(back?.expiresAt, session.expiresAt.toUtc());
      expect(back?.userId, session.userId);
      expect(back?.email, session.email);
      expect(session.toString(), isNot(contains('access-token')));
    });

    test('anything else reads as no session', () {
      expect(AuthSession.decode(null), isNull);
      expect(AuthSession.decode('not json'), isNull);
      expect(AuthSession.decode('[1]'), isNull);
      expect(AuthSession.decode('{"accessToken":"a"}'), isNull);
    });

    test('knows whether it is valid long enough', () {
      final AuthSession session = testSession(now: now);
      expect(session.validFor(const Duration(minutes: 59), now), isTrue);
      expect(session.validFor(const Duration(minutes: 61), now), isFalse);
    });
  });

  group('SecureSessionStore', () {
    test('writes, reads and clears through secure storage', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      final SecureSessionStore store = SecureSessionStore();
      expect(await store.read(), isNull);
      await store.write(testSession(now: now));
      expect((await store.read())?.email, 'aziz@example.com');
      await store.clear();
      expect(await store.read(), isNull);
    });

    test('a damaged entry is no session', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        'auth_session': '{broken',
      });
      expect(await SecureSessionStore().read(), isNull);
    });
  });

  group('SessionController', () {
    late MemorySessionStore store;
    late List<String> refreshedWith;
    late Future<TokenPairDto> Function(String) answer;

    ProviderContainer containerWith(AuthSession? initial, {DateTime? at}) {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith(
            () => SessionController(
              store: (_) => store,
              initial: (_) => initial,
              refresher: (_) => (String token) {
                refreshedWith.add(token);
                return answer(token);
              },
              now: () => at ?? now,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    setUp(() {
      store = MemorySessionStore();
      refreshedWith = <String>[];
      answer = (_) async => testPair(access: 'fresh');
    });

    test('signs in and out, keeping the store in step', () async {
      final ProviderContainer container = containerWith(null);
      expect(container.read(sessionProvider), isNull);
      await container.read(sessionProvider.notifier).signIn(testPair());
      final AuthSession? session = container.read(sessionProvider);
      expect(session?.expiresAt, now.add(const Duration(seconds: 900)));
      expect(store.session?.accessToken, 'access-token');

      await container.read(sessionProvider.notifier).signOut();
      expect(container.read(sessionProvider), isNull);
      expect(store.session, isNull);
    });

    test('hands out a valid token without refreshing', () async {
      final ProviderContainer container = containerWith(testSession(now: now));
      expect(
        await container.read(sessionProvider.notifier).accessToken(),
        'access-token',
      );
      expect(refreshedWith, isEmpty);
      // Signed out: no token.
      expect(
        await containerWith(null).read(sessionProvider.notifier).accessToken(),
        isNull,
      );
    });

    test('refreshes once for many callers when the token runs short', () async {
      final ProviderContainer container = containerWith(
        testSession(now: now),
        at: now.add(const Duration(minutes: 59, seconds: 30)),
      );
      final Completer<TokenPairDto> slow = Completer<TokenPairDto>();
      answer = (_) => slow.future;
      final SessionController controller = container.read(
        sessionProvider.notifier,
      );
      final Future<String?> a = controller.accessToken();
      final Future<String?> b = controller.accessToken();
      slow.complete(testPair(access: 'fresh'));
      expect(await a, 'fresh');
      expect(await b, 'fresh');
      expect(refreshedWith, <String>['refresh-token']);
      expect(store.session?.refreshToken, 'refresh-fresh');
    });

    test('a forced refresh happens even with time left', () async {
      final ProviderContainer container = containerWith(testSession(now: now));
      expect(
        await container
            .read(sessionProvider.notifier)
            .accessToken(forceRefresh: true),
        'fresh',
      );
    });

    test('SESSION_EXPIRED signs out; other failures pass through', () async {
      final ProviderContainer container = containerWith(testSession(now: now));
      answer = (_) async => throw const NetworkFailure();
      await expectLater(
        container
            .read(sessionProvider.notifier)
            .accessToken(forceRefresh: true),
        throwsA(isA<NetworkFailure>()),
      );
      expect(container.read(sessionProvider), isNotNull);

      answer = (_) async => throw const ServerFailure(
        code: ErrorCode.sessionExpired,
        statusCode: 401,
      );
      expect(
        await container
            .read(sessionProvider.notifier)
            .accessToken(forceRefresh: true),
        isNull,
      );
      expect(container.read(sessionProvider), isNull);
    });
  });

  group('apiTokenRefresher', () {
    test('posts the refresh token and maps errors', () async {
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test'));
      final DioAdapter adapter = DioAdapter(dio: dio)
        ..onPost(
          '/v1/auth/refresh',
          (server) => server.reply(200, testPair(access: 'next').toJson()),
          data: <String, Object?>{'refreshToken': 'r1'},
        )
        ..onPost(
          '/v1/auth/refresh',
          (server) => server.reply(401, <String, Object?>{
            'error': <String, Object?>{
              'code': 'SESSION_EXPIRED',
              'message': 'x',
              'requestId': 'req-1',
              'timestamp': '2026-10-16T12:00:00.000Z',
            },
          }),
          data: <String, Object?>{'refreshToken': 'gone'},
        );
      expect(adapter, isNotNull);
      final TokenRefresher refresh = apiTokenRefresher(dio);
      expect((await refresh('r1')).accessToken, 'next');
      await expectLater(
        refresh('gone'),
        throwsA(
          isA<ServerFailure>().having(
            (ServerFailure f) => f.code,
            'code',
            ErrorCode.sessionExpired,
          ),
        ),
      );
    });
  });

  test('sessionStoreProvider must be overridden', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    expect(() => container.read(sessionStoreProvider), throwsA(anything));
    expect(container.read(initialSessionProvider), isNull);
  });
}
