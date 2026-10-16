import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../core/api/generated/clients/auth_api.dart';
import '../../../core/api/generated/clients/me_api.dart';
import '../domain/account.dart';
import 'account_repository_impl.dart';

final Provider<AccountRepository> accountRepositoryProvider =
    Provider<AccountRepository>((Ref ref) {
      return AccountRepositoryImpl(
        me: MeApi(ref.watch(dioProvider)),
        auth: AuthApi(ref.watch(dioProvider)),
        forget: ref.read(sessionProvider.notifier).signOut,
        locale: () =>
            ref.read(appSettingsProvider).language ??
            WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      );
    });
