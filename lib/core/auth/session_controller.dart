import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/models/error_code.dart';
import '../api/generated/models/token_pair_dto.dart';
import '../errors/failure.dart';
import 'access_token_source.dart';
import 'auth_session.dart';
import 'session_store.dart';

/// Exchanges a refresh token for a new pair; throws a [Failure].
typedef TokenRefresher = Future<TokenPairDto> Function(String refreshToken);

AuthSession sessionFrom(TokenPairDto pair, DateTime now) => AuthSession(
  accessToken: pair.accessToken,
  refreshToken: pair.refreshToken,
  expiresAt: now.add(Duration(seconds: pair.expiresIn.toInt())),
  userId: pair.user.id,
  email: pair.user.email,
);

/// The current session (null: signed out) and its upkeep: persisted on every
/// change, refreshed before it expires, dropped when the server says it is
/// over (SESSION_EXPIRED: signed out elsewhere, or a reused refresh token).
class SessionController extends Notifier<AuthSession?>
    implements AccessTokenSource {
  SessionController({
    required SessionStore Function(Ref ref) store,
    required AuthSession? Function(Ref ref) initial,
    required TokenRefresher Function(Ref ref) refresher,
    DateTime Function()? now,
  }) : _storeOf = store,
       _initialOf = initial,
       _refresherOf = refresher,
       _now = now ?? DateTime.now;

  final SessionStore Function(Ref ref) _storeOf;
  final AuthSession? Function(Ref ref) _initialOf;
  final TokenRefresher Function(Ref ref) _refresherOf;
  final DateTime Function() _now;

  SessionStore get store => _storeOf(ref);

  /// One refresh at a time: refresh tokens are single use.
  Future<AuthSession?>? _refreshing;

  @override
  AuthSession? build() => _initialOf(ref);

  Future<void> signIn(TokenPairDto pair) async {
    final AuthSession session = sessionFrom(pair, _now());
    await store.write(session);
    state = session;
  }

  /// Forgets the session on this phone. The server side is the caller's job.
  Future<void> signOut() async {
    await store.clear();
    state = null;
  }

  @override
  Future<String?> accessToken({
    Duration margin = const Duration(minutes: 1),
    bool forceRefresh = false,
  }) async {
    final AuthSession? current = state;
    if (current == null) return null;
    if (!forceRefresh && current.validFor(margin, _now())) {
      return current.accessToken;
    }
    return (await _refresh(current))?.accessToken;
  }

  Future<AuthSession?> _refresh(AuthSession current) {
    final Future<AuthSession?> running = _refreshing ??= _exchange(current)
        .whenComplete(() => _refreshing = null);
    return running;
  }

  Future<AuthSession?> _exchange(AuthSession current) async {
    try {
      final TokenPairDto pair = await _refresherOf(ref)(current.refreshToken);
      final AuthSession next = sessionFrom(pair, _now());
      await store.write(next);
      state = next;
      return next;
    } on ServerFailure catch (failure) {
      if (failure.code == ErrorCode.sessionExpired ||
          failure.code == ErrorCode.unauthenticated) {
        await signOut();
        return null;
      }
      rethrow;
    }
  }
}
