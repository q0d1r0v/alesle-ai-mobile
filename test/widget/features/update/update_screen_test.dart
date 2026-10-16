import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/config/app_build.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/update/data/update_data_providers.dart';
import 'package:alesle_ai/features/update/domain/update.dart';
import 'package:alesle_ai/features/update/presentation/update_screen.dart';
import 'package:alesle_ai/features/update/presentation/update_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

const AppBuild _installed = AppBuild(
  versionCode: 3,
  versionName: '0.3.0',
  certSha256: '',
);

void main() {
  late FakeUpdateRepository updates;

  setUp(() => updates = FakeUpdateRepository());

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      screen,
      overrides: [
        updateRepositoryProvider.overrideWithValue(updates),
        appBuildProvider.overrideWithValue(_installed),
      ],
    );
    await settle(tester);
  }

  testWidgets('says when this is the latest version', (
    WidgetTester tester,
  ) async {
    updates.newest = testRelease(versionCode: 3);
    await pump(tester, const UpdateScreen());
    expect(find.text('Eng so‘nggi versiya o‘rnatilgan'), findsOneWidget);
    expect(find.text('Versiya 0.3.0 (3)'), findsOneWidget);
    expect(find.byKey(const Key('update-now')), findsNothing);
  });

  testWidgets('offers a newer version with its notes, and installs it', (
    WidgetTester tester,
  ) async {
    updates.newest = testRelease();
    await pump(tester, const UpdateScreen());
    expect(find.text('Yangi versiya chiqdi'), findsOneWidget);
    expect(find.text('Yangi versiya: 0.5.0'), findsOneWidget);
    expect(find.text('Tezroq javoblar'), findsOneWidget);
    await tester.tap(find.byKey(const Key('update-now')));
    await settle(tester);
    expect(updates.calls, <String>[
      'latest',
      'download:5',
      'install:/cache/alesle-5.apk',
    ]);
    expect(find.text('O‘rnatishni tasdiqlang.'), findsOneWidget);
  });

  testWidgets('explains each install outcome', (WidgetTester tester) async {
    final Map<InstallResult, String> messages = <InstallResult, String>{
      InstallResult.permissionNeeded: 'Alesle’ga ilova o‘rnatishga ruxsat bering, so‘ng qaytib «Yangilash»ni bosing.',
      InstallResult.corrupted: 'Fayl tekshiruvdan o‘tmadi va o‘rnatilmadi. Ilovani alesle.ai saytidan yuklab oling.',
      InstallResult.rejected: 'Fayl tekshiruvdan o‘tmadi va o‘rnatilmadi. Ilovani alesle.ai saytidan yuklab oling.',
      InstallResult.failed: 'Yangilab bo‘lmadi. Qayta urinib ko‘ring.',
    };
    for (final MapEntry<InstallResult, String> entry in messages.entries) {
      updates
        ..newest = testRelease()
        ..result = entry.key;
      await pump(tester, UpdateScreen(key: UniqueKey(), start: true));
      expect(find.text(entry.value), findsOneWidget, reason: '${entry.key}');
    }
  });

  testWidgets('a required update has no way back and can be retried', (
    WidgetTester tester,
  ) async {
    updates.failure = const NetworkFailure();
    await pump(tester, const UpdateScreen(mandatory: true));
    expect(find.byType(BackButton), findsNothing);
    expect(find.byKey(const Key('update-error')), findsOneWidget);
    updates
      ..failure = null
      ..newest = testRelease(minSupported: 4);
    await tester.tap(find.byKey(const Key('update-retry')));
    await settle(tester);
    expect(
      find.text(
        'Davom etish uchun ilovani yangilang. Bir daqiqacha vaqt oladi.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('update-now')), findsOneWidget);
  });

  testWidgets('the new-version sheet answers later or update', (
    WidgetTester tester,
  ) async {
    final List<bool> answers = <bool>[];
    await pumpLocalized(
      tester,
      Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () async =>
              answers.add(await showUpdateSheet(context, testRelease())),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('update-sheet-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('update-sheet-later')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('update-sheet-update')));
    await tester.pumpAndSettle();
    expect(answers, <bool>[false, true]);
  });
}

/// The orb turns while working: settle by time.
Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
