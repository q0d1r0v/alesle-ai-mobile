import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../core/config/app_config.dart';
import '../../core/storage/app_settings.dart';
import '../app.dart';
import 'core_providers.dart';

/// Reads the build configuration from `--dart-define-from-file`.
AppConfig configFromEnvironment() => AppConfig.parse(
  environment: const String.fromEnvironment('APP_ENV'),
  apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
  devAuthToken: const String.fromEnvironment('DEV_AUTH_TOKEN'),
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
  runApp(
    ProviderScope(
      overrides: <Override>[
        appConfigProvider.overrideWithValue(config),
        appSettingsStoreProvider.overrideWithValue(settings),
        ...overrides,
      ],
      child: const AlesleApp(),
    ),
  );
}
