import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The secret half of a magic link: made when this phone asks for a link and
/// sent back with it, so a link someone else requested cannot sign this phone
/// into their account.
abstract interface class LinkNonceStore {
  /// A fresh nonce, kept until the link is used.
  Future<String> create();

  Future<String?> read();

  Future<void> clear();
}

/// 32 random bytes, URL-safe base64 without padding (43 characters).
String newLinkNonce([Random? random]) {
  final Random source = random ?? Random.secure();
  final List<int> bytes = List<int>.generate(32, (_) => source.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

final class SecureLinkNonceStore implements LinkNonceStore {
  SecureLinkNonceStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'magic_link_nonce';
  final FlutterSecureStorage _storage;

  @override
  Future<String> create() async {
    final String nonce = newLinkNonce();
    await _storage.write(key: _key, value: nonce);
    return nonce;
  }

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

final class MemoryLinkNonceStore implements LinkNonceStore {
  String? nonce;

  @override
  Future<String> create() async => nonce = newLinkNonce();

  @override
  Future<String?> read() async => nonce;

  @override
  Future<void> clear() async => nonce = null;
}
