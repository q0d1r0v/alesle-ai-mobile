import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../core/api/generated/clients/auth_api.dart';
import '../../../core/config/app_config.dart';
import '../domain/auth_repository.dart';
import 'auth_repository_impl.dart';
import 'google_id_tokens.dart';

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) {
      final AppConfig config = ref.watch(appConfigProvider);
      final String? google = config.googleServerClientId;
      return AuthRepositoryImpl(
        api: AuthApi(ref.watch(anonymousDioProvider)),
        keep: ref.read(sessionProvider.notifier).signIn,
        locale: () =>
            ref.read(appSettingsProvider).language ??
            WidgetsBinding.instance.platformDispatcher.locale.languageCode,
        google: google == null ? null : PluginGoogleIdTokens(google),
      );
    });
