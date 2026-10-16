import 'package:alesle_ai/features/auth/domain/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads sign-in and confirmation links from alesle.ai', () {
    expect(
      EmailLink.parse(Uri.parse('https://alesle.ai/auth/link?token=abc')),
      isA<SignInLink>().having((SignInLink l) => l.token, 'token', 'abc'),
    );
    expect(
      EmailLink.parse(Uri.parse('https://alesle.ai/auth/verify?token=xyz')),
      isA<VerifyLink>().having((VerifyLink l) => l.token, 'token', 'xyz'),
    );
  });

  test('ignores other hosts, schemes, paths and missing tokens', () {
    for (final String url in <String>[
      'https://evil.example/auth/link?token=abc',
      'http://alesle.ai/auth/link?token=abc',
      'https://alesle.ai/auth/other?token=abc',
      'https://alesle.ai/auth/link',
      'https://alesle.ai/auth/link?token=',
    ]) {
      expect(EmailLink.parse(Uri.parse(url)), isNull, reason: url);
    }
  });
}
