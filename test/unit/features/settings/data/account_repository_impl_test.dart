import 'package:alesle_ai/core/api/generated/clients/auth_api.dart';
import 'package:alesle_ai/core/api/generated/clients/me_api.dart';
import 'package:alesle_ai/core/api/generated/models/deletion_dto.dart';
import 'package:alesle_ai/core/api/generated/models/locale_dto.dart';
import 'package:alesle_ai/core/api/generated/models/profile_dto.dart';
import 'package:alesle_ai/core/api/generated/models/profile_language.dart';
import 'package:alesle_ai/core/api/generated/models/session_dto.dart';
import 'package:alesle_ai/core/api/generated/models/update_profile_dto.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/settings/data/account_repository_impl.dart';
import 'package:alesle_ai/features/settings/domain/account.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeApi extends Mock implements MeApi {}

class _MockAuthApi extends Mock implements AuthApi {}

ProfileDto _profile({
  ProfileLanguage language = ProfileLanguage.ru,
  DateTime? deletion,
}) => ProfileDto(
  id: 'u1',
  email: 'aziz@example.com',
  emailVerified: false,
  displayName: 'Aziz',
  language: language,
  timeZone: 'Asia/Tashkent',
  confirmSensitiveActions: false,
  hasPassword: true,
  googleLinked: false,
  deletionScheduledAt: deletion,
);

DioException _offline() => DioException.connectionError(
  requestOptions: RequestOptions(path: '/v1/me'),
  reason: 'offline',
);

void main() {
  late _MockMeApi me;
  late _MockAuthApi auth;
  late int forgotten;
  late AccountRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const UpdateProfileDto(
        displayName: null,
        language: null,
        timeZone: null,
        confirmSensitiveActions: null,
      ),
    );
    registerFallbackValue(const LocaleDto());
  });

  setUp(() {
    me = _MockMeApi();
    auth = _MockAuthApi();
    forgotten = 0;
    repository = AccountRepositoryImpl(
      me: me,
      auth: auth,
      forget: () async => forgotten++,
      locale: () => 'ru',
    );
  });

  test('reads and updates the profile', () async {
    when(me.meProfile).thenAnswer((_) async => _profile());
    final Profile profile = await repository.profile();
    expect(profile.language, 'ru');
    expect(profile.emailVerified, isFalse);
    expect(profile.confirmSensitiveActions, isFalse);

    when(() => me.meUpdate(body: any(named: 'body')))
        .thenAnswer((_) async => _profile(language: ProfileLanguage.en));
    final Profile updated = await repository.update(
      language: 'en',
      confirmSensitiveActions: true,
    );
    expect(updated.language, 'en');
    final UpdateProfileDto sent =
        verify(() => me.meUpdate(body: captureAny(named: 'body')))
                .captured
                .single
            as UpdateProfileDto;
    expect(sent.language, ProfileLanguage.en);
    expect(sent.confirmSensitiveActions, isTrue);
    expect(sent.displayName, isNull);
    expect(sent.toJson()['displayName'], isNull);
  });

  test('lists and removes devices', () async {
    when(me.meSessions).thenAnswer(
      (_) async => <SessionDto>[
        SessionDto(
          id: 's1',
          deviceName: 'Pixel',
          createdAt: DateTime(2026),
          lastUsedAt: DateTime(2026, 10, 16),
          current: true,
        ),
      ],
    );
    when(() => me.meRemoveSession(id: 's2')).thenAnswer((_) async {});
    final List<Device> devices = await repository.devices();
    expect(devices.single.name, 'Pixel');
    expect(devices.single.current, isTrue);
    await repository.removeDevice('s2');
    verify(() => me.meRemoveSession(id: 's2')).called(1);
  });

  test(
    'signing out forgets the session even when the server is unreachable',
    () async {
      when(auth.authLogout).thenThrow(_offline());
      await repository.signOut();
      expect(forgotten, 1);
    },
  );

  test('signing out everywhere needs the server first', () async {
    when(me.meSignOutEverywhere).thenThrow(_offline());
    await expectLater(
      repository.signOutEverywhere(),
      throwsA(isA<NetworkFailure>()),
    );
    expect(forgotten, 0);
    when(me.meSignOutEverywhere).thenAnswer((_) async {});
    await repository.signOutEverywhere();
    expect(forgotten, 1);
  });

  test('deletion, cancelling it, and a fresh confirmation email', () async {
    final DateTime at = DateTime.utc(2026, 10, 23);
    when(me.meRequestDeletion)
        .thenAnswer((_) async => DeletionDto(deletionScheduledAt: at));
    when(me.meCancelDeletion).thenAnswer((_) async => _profile());
    when(() => auth.authResendVerification(body: any(named: 'body')))
        .thenAnswer((_) async {});
    expect(await repository.requestDeletion(), at);
    expect((await repository.cancelDeletion()).deletionScheduledAt, isNull);
    await repository.resendVerification();
    verify(
      () => auth.authResendVerification(body: const LocaleDto(locale: 'ru')),
    ).called(1);
  });

  test('failures come back as Failures', () async {
    when(me.meProfile).thenThrow(_offline());
    await expectLater(repository.profile(), throwsA(isA<NetworkFailure>()));
  });
}
