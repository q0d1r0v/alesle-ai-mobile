import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../core/auth/auth_session.dart';
import '../../core/auth/session_store.dart';
import '../../core/config/app_build.dart';
import '../../core/config/app_config.dart';
import '../../core/platform/app_build_reader.dart';
import '../../core/storage/app_settings.dart';
import '../app.dart';
import 'core_providers.dart';

/// Reads the build configuration from `--dart-define-from-file`.
AppConfig configFromEnvironment() => AppConfig.parse(
  environment: const String.fromEnvironment('APP_ENV'),
  apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
  googleServerClientId: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
);

/// App entry: validate configuration, then start. A misconfigured build
/// throws [AppConfigError] here instead of failing somewhere later.
Future<void> bootstrap({List<Override> overrides = const <Override>[]}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // The design is a portrait phone layout (390 × 844); the overlay works in any orientation.
  unawaited(
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]),
  );
  final AppConfig config = configFromEnvironment();
  final AppSettingsStore settings = await AppSettingsStore.load();
  final SessionStore sessions = SecureSessionStore();
  final AuthSession? session = await sessions.read();
  final AppBuild build = await readAppBuild();
  runApp(
    ProviderScope(
      overrides: <Override>[
        appConfigProvider.overrideWithValue(config),
        appSettingsStoreProvider.overrideWithValue(settings),
        sessionStoreProvider.overrideWithValue(sessions),
        initialSessionProvider.overrideWithValue(session),
        appBuildProvider.overrideWithValue(build),
        ...overrides,
      ],
      child: const AlesleApp(),
    ),
  );
}
