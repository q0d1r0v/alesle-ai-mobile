import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/app_build.dart';
import '../config/app_config.dart';

/// Crash reports (SOW 10 monitoring), stripped of anything personal before
/// they leave (AGENTS.md rule 10): no screenshots, view trees, breadcrumbs
/// (they can hold what was on screen or typed), users or requests.
void configureCrashReports(
  SentryFlutterOptions options,
  AppConfig config,
  AppBuild build,
) {
  options
    ..dsn = config.sentryDsn
    ..environment = config.environment.name
    ..release = 'com.alesle.ai@${build.versionName}+${build.versionCode}'
    ..sendDefaultPii = false
    ..attachScreenshot = false
    ..attachViewHierarchy = false
    ..maxBreadcrumbs = 0
    ..tracesSampleRate = 0
    ..beforeSend = scrubCrashReport;
}

/// What stays: the error and its stack, the release and the device model.
SentryEvent scrubCrashReport(SentryEvent event, Hint hint) {
  event
    ..user = null
    ..request = null
    ..breadcrumbs = <Breadcrumb>[]
    ..serverName = null;
  return event;
}
