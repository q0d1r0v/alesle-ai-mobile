import 'package:alesle_ai/core/api/generated/clients/auth_api.dart';
import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/api/generated/models/google_sign_in_dto.dart';
import 'package:alesle_ai/core/api/generated/models/link_token_dto.dart';
import 'package:alesle_ai/core/api/generated/models/login_dto.dart';
import 'package:alesle_ai/core/api/generated/models/magic_link_dto.dart';
import 'package:alesle_ai/core/api/generated/models/magic_link_sign_in_dto.dart';
import 'package:alesle_ai/core/api/generated/models/register_dto.dart';
import 'package:alesle_ai/core/api/generated/models/token_pair_dto.dart';
import 'package:alesle_ai/core/auth/link_nonce_store.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/auth/data/auth_repository_impl.dart';
import 'package:alesle_ai/features/auth/data/google_id_tokens.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _MockDeviceHostApi extends Mock implements DeviceHostApi {}

class _FakeGoogle implements GoogleIdTokens {
  String? token = 'google-id-token';
  Object? failure;

  @override
  Future<String?> idToken() async {
    if (failure case final Object value) throw value;
    return token;
  }
}

DioException _refused(String code, int status) => DioException(
  requestOptions: RequestOptions(path: '/v1/auth/login'),
  type: DioExceptionType.badResponse,
  response: Response<Object?>(
    requestOptions: RequestOptions(path: '/v1/auth/login'),
    statusCode: status,
    data: <String, Object?>{
      'error': <String, Object?>{
        'code': code,
        'message': 'x',
        'requestId': 'r',
        'timestamp': '2026-10-16T12:00:00.000Z',
      },
    },
  ),
);

void main() {
  late _MockAuthApi api;
  late _MockDeviceHostApi device;
  late _FakeGoogle google;
  late List<TokenPairDto> kept;
  late AuthRepositoryImpl repository;
  late _MockAuthApi authed;
  late MemoryLinkNonceStore nonces;

  setUpAll(() {
    registerFallbackValue(const LoginDto(email: '', password: ''));
    registerFallbackValue(const RegisterDto(email: '', password: ''));
    registerFallbackValue(const GoogleSignInDto(idToken: ''));
    registerFallbackValue(const MagicLinkDto(email: '', nonce: ''));
    registerFallbackValue(const MagicLinkSignInDto(token: '', nonce: ''));
    registerFallbackValue(const LinkTokenDto(token: ''));
  });

  setUp(() {
    api = _MockAuthApi();
    authed = _MockAuthApi();
    nonces = MemoryLinkNonceStore();
    device = _MockDeviceHostApi();
    google = _FakeGoogle();
    kept = <TokenPairDto>[];
    when(device.setupState).thenAnswer(
      (_) async => DeviceSetupMessage(
        batteryOptimizationIgnored: true,
        manufacturer: 'google',
        sdkInt: 35,
        deviceName: 'Google Pixel 7',
      ),
    );
    repository = AuthRepositoryImpl(
      api: api,
      authed: authed,
      nonces: nonces,
      keep: (TokenPairDto pair) async => kept.add(pair),
      locale: () => 'ru',
      google: google,
      device: device,
    );
  });

  test('password sign-in sends the device and keeps the pair', () async {
    when(() => api.authLogin(body: any(named: 'body')))
        .thenAnswer((_) async => testPair());
    await repository.signInWithPassword(
      email: ' a@b.uz ',
      password: 'secret12',
    );
    final LoginDto sent =
        verify(() => api.authLogin(body: captureAny(named: 'body')))
                .captured
                .single
            as LoginDto;
    expect(sent.email, 'a@b.uz');
    expect(sent.deviceName, 'Google Pixel 7');
    expect(sent.locale, 'ru');
    expect(kept.single.accessToken, 'access-token');
    // The device name is asked for once.
    await repository.signInWithPassword(email: 'a@b.uz', password: 'secret12');
    verify(device.setupState).called(1);
  });

  test('registering trims an optional name', () async {
    when(() => api.authRegister(body: any(named: 'body')))
        .thenAnswer((_) async => testPair());
    await repository.register(
      email: 'a@b.uz',
      password: 'secret12',
      displayName: '  ',
    );
    await repository.register(
      email: 'a@b.uz',
      password: 'secret12',
      displayName: ' Aziz ',
    );
    final List<Object?> sent = verify(
      () => api.authRegister(body: captureAny(named: 'body')),
    ).captured;
    expect((sent[0]! as RegisterDto).displayName, isNull);
    expect((sent[1]! as RegisterDto).displayName, 'Aziz');
  });

  test('server refusals become ServerFailures and keep nothing', () async {
    when(() => api.authLogin(body: any(named: 'body')))
        .thenThrow(_refused('INVALID_CREDENTIALS', 401));
    await expectLater(
      repository.signInWithPassword(email: 'a@b.uz', password: 'wrongpass'),
      throwsA(
        isA<ServerFailure>().having(
          (ServerFailure f) => f.code,
          'code',
          ErrorCode.invalidCredentials,
        ),
      ),
    );
    expect(kept, isEmpty);
  });

  test(
    'Google: signs in, or reports a cancel, or wraps plugin errors',
    () async {
      when(() => api.authGoogle(body: any(named: 'body')))
          .thenAnswer((_) async => testPair());
      expect(repository.googleAvailable, isTrue);
      expect(await repository.signInWithGoogle(), isTrue);
      final GoogleSignInDto sent =
          verify(() => api.authGoogle(body: captureAny(named: 'body')))
                  .captured
                  .single
              as GoogleSignInDto;
      expect(sent.idToken, 'google-id-token');

      google.token = null;
      expect(await repository.signInWithGoogle(), isFalse);

      google.failure = PlatformException(code: 'no-play-services');
      await expectLater(
        repository.signInWithGoogle(),
        throwsA(isA<UnexpectedFailure>()),
      );

      final AuthRepositoryImpl noGoogle = AuthRepositoryImpl(
        api: api,
        authed: authed,
        nonces: nonces,
        keep: (_) async {},
        locale: () => 'uz',
        device: device,
      );
      expect(noGoogle.googleAvailable, isFalse);
      expect(await noGoogle.signInWithGoogle(), isFalse);
    },
  );

  test('magic links and email confirmation', () async {
    when(() => api.authMagicLink(body: any(named: 'body')))
        .thenAnswer((_) async {});
    when(() => api.authVerifyMagicLink(body: any(named: 'body')))
        .thenAnswer((_) async => testPair());
    when(() => authed.authVerifyEmail(body: any(named: 'body')))
        .thenAnswer((_) async {});

    await repository.sendMagicLink(' a@b.uz ');
    final MagicLinkDto link =
        verify(() => api.authMagicLink(body: captureAny(named: 'body')))
                .captured
                .single
            as MagicLinkDto;
    expect(link.email, 'a@b.uz');
    expect(link.locale, 'ru');
    // The nonce stays on this phone until the link comes back.
    expect(link.nonce, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(nonces.nonce, link.nonce);

    await repository.signInWithMagicLink('tok');
    final MagicLinkSignInDto signIn =
        verify(() => api.authVerifyMagicLink(body: captureAny(named: 'body')))
                .captured
                .single
            as MagicLinkSignInDto;
    expect(signIn.nonce, link.nonce);
    expect(kept, hasLength(1));
    expect(nonces.nonce, isNull);

    // No link asked for here: a throwaway nonce, which the server refuses.
    await repository.signInWithMagicLink('foreign');
    final MagicLinkSignInDto foreign =
        verify(() => api.authVerifyMagicLink(body: captureAny(named: 'body')))
                .captured
                .single
            as MagicLinkSignInDto;
    expect(foreign.nonce, isNot(link.nonce));
    expect(foreign.nonce, hasLength(43));

    // Confirming goes as the signed-in user.
    await repository.verifyEmail('v');
    verify(() => authed.authVerifyEmail(body: const LinkTokenDto(token: 'v')))
        .called(1);
    verifyNever(() => api.authVerifyEmail(body: any(named: 'body')));

    when(() => api.authMagicLink(body: any(named: 'body')))
        .thenThrow(_refused('RATE_LIMITED', 429));
    when(() => authed.authVerifyEmail(body: any(named: 'body')))
        .thenThrow(_refused('LINK_INVALID', 400));
    await expectLater(
      repository.sendMagicLink('a@b.uz'),
      throwsA(isA<ServerFailure>()),
    );
    await expectLater(
      repository.verifyEmail('v'),
      throwsA(isA<ServerFailure>()),
    );
  });

  test('a phone that will not say its name signs in without one', () async {
    when(device.setupState).thenThrow(PlatformException(code: 'x'));
    when(() => api.authLogin(body: any(named: 'body')))
        .thenAnswer((_) async => testPair());
    await repository.signInWithPassword(email: 'a@b.uz', password: 'secret12');
    final LoginDto sent =
        verify(() => api.authLogin(body: captureAny(named: 'body')))
                .captured
                .single
            as LoginDto;
    expect(sent.deviceName, isNull);
  });
}
