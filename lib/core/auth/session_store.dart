import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session.dart';

/// Where the session survives app restarts.
abstract interface class SessionStore {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

/// Android Keystore-encrypted storage (flutter_secure_storage).
final class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'auth_session';
  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> read() async {
    try {
      return AuthSession.decode(await _storage.read(key: _key));
    } on Object {
      // Keystore trouble (restored backup, changed lock): sign in again.
      return null;
    }
  }

  @override
  Future<void> write(AuthSession session) =>
      _storage.write(key: _key, value: session.encode());

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// For tests, and the sessionless start of a widget test.
final class MemorySessionStore implements SessionStore {
  MemorySessionStore([this.session]);

  AuthSession? session;

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession session) async => this.session = session;

  @override
  Future<void> clear() async => session = null;
}
