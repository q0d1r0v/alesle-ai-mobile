import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../core/config/app_config.dart';
import '../app.dart';
import 'core_providers.dart';

/// Reads the build configuration from `--dart-define-from-file`.
AppConfig configFromEnvironment() => AppConfig.parse(
  environment: const String.fromEnvironment('APP_ENV'),
  apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
);

/// App entry: validate configuration, then start. A misconfigured build
/// throws [AppConfigError] here instead of failing somewhere later.
void bootstrap({List<Override> overrides = const <Override>[]}) {
  WidgetsFlutterBinding.ensureInitialized();
  final AppConfig config = configFromEnvironment();
  runApp(
    ProviderScope(
      overrides: <Override>[
        appConfigProvider.overrideWithValue(config),
        ...overrides,
      ],
      child: const AlesleApp(),
    ),
  );
}
