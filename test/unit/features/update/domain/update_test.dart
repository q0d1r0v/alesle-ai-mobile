import 'package:alesle_ai/features/update/domain/update.dart';
import 'package:flutter_test/flutter_test.dart';

Release _release({int code = 5, int min = 3}) => Release(
  versionCode: code,
  versionName: '0.$code.0',
  apkUrl: Uri.parse('https://cdn.alesle.ai/a.apk'),
  sha256: 'a' * 64,
  certSha256: 'b' * 64,
  sizeBytes: 1,
  minSupportedVersionCode: min,
  notes: const <String, String>{'en': 'Faster', 'uz': 'Tezroq'},
);

void main() {
  test('an update is needed only for a newer release', () {
    expect(updateNeed(5, null), UpdateNeed.none);
    expect(updateNeed(5, _release()), UpdateNeed.none);
    expect(updateNeed(6, _release()), UpdateNeed.none);
    expect(updateNeed(4, _release()), UpdateNeed.optional);
    expect(updateNeed(3, _release()), UpdateNeed.optional);
    expect(updateNeed(2, _release()), UpdateNeed.required);
  });

  test('notes in the user’s language, else English', () {
    expect(_release().notesIn('uz'), 'Tezroq');
    expect(_release().notesIn('ru'), 'Faster');
    final Release bare = Release(
      versionCode: 1,
      versionName: '0.1.0',
      apkUrl: Uri.parse('https://x'),
      sha256: '',
      certSha256: '',
      sizeBytes: 1,
      minSupportedVersionCode: 1,
      notes: const <String, String>{},
    );
    expect(bare.notesIn('uz'), '');
  });

  test('the manifest is read at opening and then daily', () {
    final DateTime now = DateTime(2026, 10, 16, 12);
    expect(updateCheckDue(null, now), isTrue);
    expect(
      updateCheckDue(now.subtract(const Duration(hours: 23)), now),
      isFalse,
    );
    expect(updateCheckDue(now.subtract(const Duration(days: 1)), now), isTrue);
  });
}
