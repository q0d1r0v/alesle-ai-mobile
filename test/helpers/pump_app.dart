import 'package:alesle_ai/app/account_links.dart';
import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/app/l10n/app_localizations.dart';
import 'package:alesle_ai/app/theme/app_theme.dart';
import 'package:alesle_ai/core/auth/auth_session.dart';
import 'package:alesle_ai/core/auth/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Pumps [child] inside the same localization and theme setup as the app.
Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('uz'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildTheme(),
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<Object?>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

/// The app as a signed-in user, with no links coming in.
List<Override> signedInOverrides({AuthSession? session}) {
  final AuthSession current = session ?? testSession();
  return <Override>[
    sessionStoreProvider.overrideWithValue(MemorySessionStore(current)),
    initialSessionProvider.overrideWithValue(current),
    incomingLinksProvider.overrideWithValue(const Stream<Uri>.empty()),
  ];
}

/// The app as nobody: signed out, no links coming in.
List<Override> signedOutOverrides({MemorySessionStore? store}) => <Override>[
  sessionStoreProvider.overrideWithValue(store ?? MemorySessionStore()),
  initialSessionProvider.overrideWithValue(null),
  incomingLinksProvider.overrideWithValue(const Stream<Uri>.empty()),
];
