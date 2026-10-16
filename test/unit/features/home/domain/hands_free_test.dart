import 'package:alesle_ai/features/home/domain/hands_free.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only a bare stop stops, in three languages', () {
    for (final String said in <String>[
      "To'xta!",
      'to‘xtat',
      'Alesle, stop',
      'bekor qil',
      'Хватит.',
      'стоп пожалуйста',
      'Cancel',
      'bas',
    ]) {
      expect(isStopCommand(said), isTrue, reason: said);
    }
    for (final String said in <String>[
      "Taymerni to'xtat",
      'stop the music',
      'bekor',
      'qil',
      'Onamga yoz',
      '',
      'iltimos',
      'to‘xta va onamga yoz',
    ]) {
      expect(isStopCommand(said), isFalse, reason: said);
    }
  });

  test('the reply follows the language heard, else the app', () {
    expect(replyLocale('ru', 'uz'), 'ru');
    expect(replyLocale('other', 'uz'), 'uz');
    expect(replyLocale('de', 'en'), 'en');
  });

  test('listen status compares by value', () {
    expect(
      const ListenStatus(active: true, muted: false),
      const ListenStatus(active: true, muted: false),
    );
    expect(
      const ListenStatus(active: true, muted: false).hashCode,
      const ListenStatus(active: true, muted: false).hashCode,
    );
    expect(
      ListenStatus.off,
      isNot(const ListenStatus(active: true, muted: false)),
    );
  });
}
