import 'package:alesle_ai/core/config/legal_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('links to the page in the user’s language, else English', () {
    expect(
      webPageUrl(WebPage.privacy, 'uz').toString(),
      'https://alesle.ai/uz/privacy',
    );
    expect(
      webPageUrl(WebPage.deleteAccount, 'ru').toString(),
      'https://alesle.ai/ru/delete-account',
    );
    expect(
      webPageUrl(WebPage.refund, 'de').toString(),
      'https://alesle.ai/en/refund',
    );
  });
}
