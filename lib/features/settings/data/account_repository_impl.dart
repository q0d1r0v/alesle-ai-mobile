import '../../../core/api/generated/clients/auth_api.dart';
import '../../../core/api/generated/clients/me_api.dart';
import '../../../core/api/generated/models/deletion_dto.dart';
import '../../../core/api/generated/models/locale_dto.dart';
import '../../../core/api/generated/models/profile_dto.dart';
import '../../../core/api/generated/models/profile_language.dart';
import '../../../core/api/generated/models/session_dto.dart';
import '../../../core/api/generated/models/update_profile_dto.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../domain/account.dart';

final class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required this._me,
    required this._auth,
    required this._forget,
    required this._locale,
  });

  final MeApi _me;

  /// Signed in: logout and resend need the user's token.
  final AuthApi _auth;

  /// Drops the session on this phone.
  final Future<void> Function() _forget;
  final String Function() _locale;

  @override
  Future<Profile> profile() =>
      _call(() async => _profile(await _me.meProfile()));

  @override
  Future<Profile> update({
    String? displayName,
    String? language,
    bool? confirmSensitiveActions,
  }) => _call(
    () async => _profile(
      await _me.meUpdate(
        body: UpdateProfileDto(
          displayName: displayName,
          language: language == null
              ? null
              : ProfileLanguage.fromJson(language),
          timeZone: null,
          confirmSensitiveActions: confirmSensitiveActions,
        ),
      ),
    ),
  );

  @override
  Future<void> resendVerification() => _call(
    () => _auth.authResendVerification(body: LocaleDto(locale: _locale())),
  );

  @override
  Future<List<Device>> devices() => _call(() async {
    final List<SessionDto> sessions = await _me.meSessions();
    return <Device>[
      for (final SessionDto session in sessions)
        Device(
          id: session.id,
          name: session.deviceName,
          lastUsedAt: session.lastUsedAt,
          current: session.current,
        ),
    ];
  });

  @override
  Future<void> removeDevice(String id) =>
      _call(() => _me.meRemoveSession(id: id));

  @override
  Future<void> signOut() async {
    try {
      await _auth.authLogout();
    } on Object {
      // Offline or already signed out there: this phone forgets it anyway.
    } finally {
      await _forget();
    }
  }

  @override
  Future<void> signOutEverywhere() async {
    await _call(_me.meSignOutEverywhere);
    await _forget();
  }

  @override
  Future<DateTime> requestDeletion() => _call(() async {
    final DeletionDto deletion = await _me.meRequestDeletion();
    return deletion.deletionScheduledAt;
  });

  @override
  Future<Profile> cancelDeletion() =>
      _call(() async => _profile(await _me.meCancelDeletion()));

  static Profile _profile(ProfileDto dto) => Profile(
    email: dto.email,
    emailVerified: dto.emailVerified,
    displayName: dto.displayName,
    language: dto.language.json ?? 'uz',
    confirmSensitiveActions: dto.confirmSensitiveActions,
    deletionScheduledAt: dto.deletionScheduledAt,
  );

  static Future<T> _call<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (error) {
      throw mapToFailure(error);
    }
  }
}
