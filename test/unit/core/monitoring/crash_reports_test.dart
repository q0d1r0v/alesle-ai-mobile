import 'package:alesle_ai/core/config/app_build.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/monitoring/crash_reports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  test('reports carry no screenshots, view trees, breadcrumbs or users', () {
    final SentryFlutterOptions options = SentryFlutterOptions();
    configureCrashReports(
      options,
      const AppConfig(
        environment: AppEnvironment.prod,
        apiBaseUrl: 'https://api.alesle.ai',
        sentryDsn: 'https://key@o1.ingest.sentry.io/1',
      ),
      const AppBuild(versionCode: 3, versionName: '0.3.0', certSha256: ''),
    );
    expect(options.dsn, 'https://key@o1.ingest.sentry.io/1');
    expect(options.environment, 'prod');
    expect(options.release, 'com.alesle.ai@0.3.0+3');
    expect(options.sendDefaultPii, isFalse);
    expect(options.attachScreenshot, isFalse);
    expect(options.attachViewHierarchy, isFalse);
    expect(options.maxBreadcrumbs, 0);
  });

  test('a report is scrubbed before it leaves', () {
    final SentryEvent event = SentryEvent(
      user: SentryUser(email: 'a@b.uz'),
      breadcrumbs: <Breadcrumb>[Breadcrumb(message: 'typed: salom')],
      serverName: 'phone',
    );
    final SentryEvent scrubbed = scrubCrashReport(event, Hint());
    expect(scrubbed.user, isNull);
    expect(scrubbed.breadcrumbs, isEmpty);
    expect(scrubbed.serverName, isNull);
    expect(scrubbed.request, isNull);
  });
}
