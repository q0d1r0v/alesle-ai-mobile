import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:alesle_ai/features/settings/data/settings_data_providers.dart';
import 'package:alesle_ai/features/settings/domain/account.dart';
import 'package:alesle_ai/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeAccountRepository account;
  late AppSettingsStore store;

  Future<ProviderContainer> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    store = await testSettingsStore(language: 'uz');
    await pumpLocalized(
      tester,
      const SettingsScreen(),
      overrides: [
        accountRepositoryProvider.overrideWithValue(account),
        appSettingsStoreProvider.overrideWithValue(store),
      ],
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final Finder target = find.byKey(Key(key));
    // The list builds lazily: scroll rows below the fold into existence.
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        target,
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  setUp(() => account = FakeAccountRepository());

  testWidgets(
    'shows the account and keeps the server’s settings on the phone',
    (WidgetTester tester) async {
      account.current = const Profile(
        email: 'aziz@example.com',
        emailVerified: true,
        displayName: 'Aziz',
        language: 'uz',
        confirmSensitiveActions: false,
        deletionScheduledAt: null,
      );
      final ProviderContainer container = await pump(tester);
      expect(find.text('aziz@example.com'), findsOneWidget);
      expect(find.text('Aziz'), findsOneWidget);
      expect(find.text('Google Pixel 7'), findsOneWidget);
      expect(find.text('Shu qurilma'), findsOneWidget);
      expect(
        container.read(appSettingsProvider).confirmSensitiveActions,
        isFalse,
      );
    },
  );

  testWidgets('changes the name, language and confirmation setting', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pump(tester);
    await tap(tester, 'settings-name');
    await tester.enterText(
      find.byKey(const Key('settings-name-field')),
      'Aziza',
    );
    await tap(tester, 'settings-name-save');
    expect(account.calls, contains('update:Aziza::'));
    expect(find.text('Aziza'), findsOneWidget);

    await tap(tester, 'settings-language');
    await tap(tester, 'settings-language-ru');
    expect(account.calls, contains('update::ru:'));
    expect(container.read(appSettingsProvider).language, 'ru');

    await tap(tester, 'settings-confirm');
    expect(account.calls, contains('update:::false'));
    expect(
      container.read(appSettingsProvider).confirmSensitiveActions,
      isFalse,
    );
  });

  testWidgets('voice replies is a phone-only switch', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pump(tester);
    await tap(tester, 'settings-voice');
    expect(container.read(appSettingsProvider).voiceReplies, isFalse);
    expect(store.read().voiceReplies, isFalse);
  });

  testWidgets('an unconfirmed email can ask for the link again', (
    WidgetTester tester,
  ) async {
    account.current = const Profile(
      email: 'aziz@example.com',
      emailVerified: false,
      displayName: null,
      language: 'uz',
      confirmSensitiveActions: true,
      deletionScheduledAt: null,
    );
    await pump(tester);
    expect(find.text('Tasdiqlanmagan'), findsOneWidget);
    expect(find.text('Kiritilmagan'), findsOneWidget);
    await tap(tester, 'settings-resend');
    expect(account.calls, contains('resend'));
    expect(find.text('Xat yuborildi.'), findsOneWidget);
  });

  testWidgets('removes another device; this one cannot be removed here', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(find.byKey(const Key('settings-remove-d1')), findsNothing);
    await tap(tester, 'settings-remove-d2');
    expect(account.calls, contains('remove:d2'));
    expect(find.text('Tablet'), findsNothing);
  });

  testWidgets('signs out here or everywhere', (WidgetTester tester) async {
    await pump(tester);
    await tap(tester, 'settings-sign-out');
    await tap(tester, 'settings-sign-out-everywhere');
    expect(
      account.calls,
      containsAll(<String>['signOut', 'signOutEverywhere']),
    );
  });

  testWidgets('deleting asks first, then offers to cancel', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await tap(tester, 'settings-delete');
    expect(find.text('Akkaunt o‘chirilsinmi?'), findsOneWidget);
    await tester.tap(find.text('Bekor qilish'));
    await tester.pumpAndSettle();
    expect(account.calls, isNot(contains('delete')));

    await tap(tester, 'settings-delete');
    await tap(tester, 'settings-delete-confirm');
    expect(account.calls, contains('delete'));
    expect(
      find.byKey(const Key('settings-deletion-scheduled')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('settings-delete')), findsNothing);

    await tap(tester, 'settings-cancel-deletion');
    expect(find.byKey(const Key('settings-deletion-scheduled')), findsNothing);
  });

  testWidgets('a failed load can be retried; a failed change says why', (
    WidgetTester tester,
  ) async {
    account.failure = const NetworkFailure();
    await pump(tester);
    expect(find.byKey(const Key('settings-load-error')), findsOneWidget);
    account.failure = null;
    await tap(tester, 'settings-retry');
    expect(find.text('aziz@example.com'), findsOneWidget);

    account.failure = const NetworkFailure();
    await tap(tester, 'settings-confirm');
    expect(find.text('Internet aloqasini tekshiring'), findsOneWidget);
  });
}
