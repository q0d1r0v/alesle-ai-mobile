import 'package:flutter/services.dart';

import '../../../core/api/generated/clients/auth_api.dart';
import '../../../core/api/generated/models/google_sign_in_dto.dart';
import '../../../core/api/generated/models/link_token_dto.dart';
import '../../../core/api/generated/models/login_dto.dart';
import '../../../core/api/generated/models/magic_link_dto.dart';
import '../../../core/api/generated/models/register_dto.dart';
import '../../../core/api/generated/models/token_pair_dto.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/auth_repository.dart';
import 'google_id_tokens.dart';

/// Keeps the pair a sign-in returned (the session controller).
typedef SessionSink = Future<void> Function(TokenPairDto pair);

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._api,
    required this._keep,
    required this._locale,
    this._google,
    DeviceHostApi? device,
  }) : _device = device ?? DeviceHostApi();

  /// Anonymous: sign-in calls carry no token.
  final AuthApi _api;
  final SessionSink _keep;

  /// The app language, for the emails the server sends.
  final String Function() _locale;
  final GoogleIdTokens? _google;
  final DeviceHostApi _device;
  String? _deviceName;

  @override
  bool get googleAvailable => _google != null;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) => _signIn(
    () async => _api.authLogin(
      body: LoginDto(
        email: email.trim(),
        password: password,
        deviceName: await _name(),
        locale: _locale(),
      ),
    ),
  );

  @override
  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) => _signIn(
    () async => _api.authRegister(
      body: RegisterDto(
        email: email.trim(),
        password: password,
        displayName: (displayName?.trim().isEmpty ?? true)
            ? null
            : displayName!.trim(),
        deviceName: await _name(),
        locale: _locale(),
      ),
    ),
  );

  @override
  Future<bool> signInWithGoogle() async {
    final GoogleIdTokens? google = _google;
    if (google == null) return false;
    final String? idToken;
    try {
      idToken = await google.idToken();
    } on Object catch (error) {
      throw UnexpectedFailure(error);
    }
    if (idToken == null) return false;
    await _signIn(
      () async => _api.authGoogle(
        body: GoogleSignInDto(
          idToken: idToken!,
          deviceName: await _name(),
          locale: _locale(),
        ),
      ),
    );
    return true;
  }

  @override
  Future<void> sendMagicLink(String email) async {
    try {
      await _api.authMagicLink(
        body: MagicLinkDto(email: email.trim(), locale: _locale()),
      );
    } on Object catch (error) {
      throw mapToFailure(error);
    }
  }

  @override
  Future<void> signInWithMagicLink(String token) => _signIn(
    () async => _api.authVerifyMagicLink(
      body: LinkTokenDto(
        token: token,
        deviceName: await _name(),
        locale: _locale(),
      ),
    ),
  );

  @override
  Future<void> verifyEmail(String token) async {
    try {
      await _api.authVerifyEmail(body: LinkTokenDto(token: token));
    } on Object catch (error) {
      throw mapToFailure(error);
    }
  }

  Future<void> _signIn(Future<TokenPairDto> Function() call) async {
    final TokenPairDto pair;
    try {
      pair = await call();
    } on Object catch (error) {
      throw mapToFailure(error);
    }
    await _keep(pair);
  }

  /// "Google Pixel 7" for the device list; null if the phone will not say.
  Future<String?> _name() async {
    if (_deviceName != null) return _deviceName;
    try {
      _deviceName = (await _device.setupState()).deviceName;
    } on PlatformException {
      return null;
    }
    return _deviceName;
  }
}
