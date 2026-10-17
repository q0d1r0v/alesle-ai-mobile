import 'package:alesle_ai/app/l10n/app_localizations_uz.dart';
import 'package:alesle_ai/features/home/presentation/live_examples.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('eight everyday examples, none about a particular person', () {
    final List<String> all = liveExamples(AppLocalizationsUz());
    expect(all, hasLength(8));
    expect(all.toSet(), hasLength(8));
    expect(all.where((String e) => e.contains('Onam')), isEmpty);
  });

  test('picks three different ones, another set for another seed', () {
    const List<String> all = <String>['a', 'b', 'c', 'd', 'e'];
    expect(pickExamples(all, 0), <String>['a', 'b', 'c']);
    expect(pickExamples(all, 4), <String>['e', 'a', 'b']);
    expect(pickExamples(all, -7), <String>['c', 'd', 'e']);
    expect(pickExamples(all, 1, count: 9), hasLength(5));
    expect(pickExamples(const <String>[], 3), isEmpty);
  });
}
