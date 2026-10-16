import 'dart:math';

import 'package:alesle_ai/core/auth/link_nonce_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nonces are 43 URL-safe characters and differ', () {
    final String a = newLinkNonce();
    expect(a, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(newLinkNonce(), isNot(a));
    expect(newLinkNonce(Random(1)), newLinkNonce(Random(1)));
  });

  test('the secure store keeps one nonce until cleared', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    final SecureLinkNonceStore store = SecureLinkNonceStore();
    expect(await store.read(), isNull);
    final String nonce = await store.create();
    expect(await store.read(), nonce);
    await store.clear();
    expect(await store.read(), isNull);
  });

  test('the memory store does the same', () async {
    final MemoryLinkNonceStore store = MemoryLinkNonceStore();
    final String nonce = await store.create();
    expect(await store.read(), nonce);
    await store.clear();
    expect(await store.read(), isNull);
  });
}
