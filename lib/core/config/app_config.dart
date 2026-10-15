/// Which backend the build talks to.
enum AppEnvironment { dev, staging, prod }

/// Thrown at startup when the build was configured incorrectly. Never caught:
/// a misconfigured build must not reach a user.
final class AppConfigError extends Error {
  AppConfigError(this.message);

  final String message;

  @override
  String toString() => 'AppConfigError: $message';
}

/// Build-time configuration, validated once at startup.
///
/// Values come from `--dart-define-from-file=env/<env>.json`.
/// [AppConfig.parse] is pure so every rule is unit-tested.
final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.devAuthToken,
  });

  /// Validates raw build values. [apiBaseUrl] must be an origin only
  /// (scheme + host + optional port): generated client paths already start
  /// with `/v1`, so a path here would double it.
  ///
  /// [devAuthToken] is the API's development token (alesle-ai-api D14),
  /// accepted in dev builds only and only until accounts exist (Sprint 5).
  /// Pass it with `--dart-define=DEV_AUTH_TOKEN=…`, never in a committed file.
  factory AppConfig.parse({
    required String environment,
    required String apiBaseUrl,
    String devAuthToken = '',
  }) {
    final AppEnvironment env = AppEnvironment.values.firstWhere(
      (AppEnvironment value) => value.name == environment,
      orElse: () => throw AppConfigError(
        'APP_ENV must be one of ${AppEnvironment.values.map((e) => e.name).join(', ')}; '
        'got "$environment". Build with --dart-define-from-file=env/<env>.json.',
      ),
    );

    final Uri? uri = Uri.tryParse(apiBaseUrl);
    if (uri == null ||
        !uri.hasScheme ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      throw AppConfigError(
        'API_BASE_URL must be an absolute http(s) URL; got "$apiBaseUrl".',
      );
    }
    if ((uri.path.isNotEmpty && uri.path != '/') ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw AppConfigError(
        'API_BASE_URL must be an origin only (no path, query or fragment); '
        'got "$apiBaseUrl".',
      );
    }
    if (env == AppEnvironment.prod && uri.scheme != 'https') {
      throw AppConfigError('API_BASE_URL must use https in prod.');
    }

    final String token = devAuthToken.trim();
    if (token.isNotEmpty && env != AppEnvironment.dev) {
      throw AppConfigError(
        'DEV_AUTH_TOKEN is for dev builds only; got one for ${env.name}.',
      );
    }

    return AppConfig(
      environment: env,
      apiBaseUrl: uri.replace(path: '').toString(),
      devAuthToken: token.isEmpty ? null : token,
    );
  }

  final AppEnvironment environment;

  /// Origin of the API, without a trailing slash.
  final String apiBaseUrl;

  /// The development bearer token, or null (always null outside dev).
  final String? devAuthToken;
}
