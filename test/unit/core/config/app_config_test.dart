import 'package:alesle_ai/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppConfig parse({
    String environment = 'dev',
    String apiBaseUrl = 'http://10.0.2.2:3000',
    String googleServerClientId = '',
  }) => AppConfig.parse(
    environment: environment,
    apiBaseUrl: apiBaseUrl,
    googleServerClientId: googleServerClientId,
  );

  group('AppConfig.parse', () {
    test('accepts a valid dev configuration', () {
      final AppConfig config = parse();
      expect(config.environment, AppEnvironment.dev);
      expect(config.apiBaseUrl, 'http://10.0.2.2:3000');
    });

    test('takes a Google OAuth client ID, or none', () {
      expect(parse().googleServerClientId, isNull);
      expect(parse(googleServerClientId: '  ').googleServerClientId, isNull);
      expect(
        parse(googleServerClientId: ' 123-abc.apps.googleusercontent.com ')
            .googleServerClientId,
        '123-abc.apps.googleusercontent.com',
      );
      expect(
        () => parse(googleServerClientId: 'not-a-client-id'),
        throwsA(isA<AppConfigError>()),
      );
    });

    test('strips a trailing slash from the origin', () {
      expect(
        parse(apiBaseUrl: 'https://api.alesle.ai/').apiBaseUrl,
        'https://api.alesle.ai',
      );
    });

    test('rejects an unknown or missing environment', () {
      expect(() => parse(environment: ''), throwsA(isA<AppConfigError>()));
      expect(
        () => parse(environment: 'production'),
        throwsA(isA<AppConfigError>()),
      );
    });

    test('rejects a base URL that is not an absolute http(s) origin', () {
      for (final String bad in <String>[
        '',
        'api.alesle.ai',
        'ftp://api.alesle.ai',
        'https://',
        'https://api.alesle.ai/v1',
        'https://api.alesle.ai?x=1',
        'https://api.alesle.ai#frag',
      ]) {
        expect(
          () => parse(apiBaseUrl: bad),
          throwsA(isA<AppConfigError>()),
          reason: bad,
        );
      }
    });

    test('requires https in prod', () {
      expect(
        () => parse(environment: 'prod', apiBaseUrl: 'http://api.alesle.ai'),
        throwsA(
          isA<AppConfigError>().having(
            (AppConfigError e) => e.message,
            'message',
            contains('https'),
          ),
        ),
      );
      expect(
        parse(
          environment: 'prod',
          apiBaseUrl: 'https://api.alesle.ai',
        ).environment,
        AppEnvironment.prod,
      );
    });

    test('error describes itself', () {
      expect(AppConfigError('x').toString(), 'AppConfigError: x');
    });
  });
}
