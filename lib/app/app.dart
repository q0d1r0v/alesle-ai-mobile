import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_links.dart';
import 'bootstrap/core_providers.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Uzbek first: it is the product's primary language and the fallback for
/// any device locale the app does not ship.
const Locale fallbackLocale = Locale('uz');

Locale resolveLocale(Locale? device, Iterable<Locale> supported) {
  if (device == null) return fallbackLocale;
  for (final Locale locale in supported) {
    if (locale.languageCode == device.languageCode) return locale;
  }
  return fallbackLocale;
}

class AlesleApp extends ConsumerWidget {
  const AlesleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? language = ref.watch(
      appSettingsProvider.select((settings) => settings.language),
    );
    return MaterialApp.router(
      // null follows the phone; a choice made in onboarding or settings wins.
      locale: language == null ? null : Locale(language),
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      // The design system is light-only for now ("Design system v3 · Light").
      theme: buildTheme(),
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
      scaffoldMessengerKey: appMessengerKey,
      builder: (BuildContext context, Widget? child) =>
          AccountLinks(child: child ?? const SizedBox.shrink()),
      localizationsDelegates: const <LocalizationsDelegate<Object?>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: resolveLocale,
      debugShowCheckedModeBanner: false,
    );
  }
}
