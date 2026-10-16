import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/memory/data/memory_data_providers.dart';
import 'package:alesle_ai/features/memory/domain/memory.dart';
import 'package:alesle_ai/features/memory/presentation/history_screen.dart';
import 'package:alesle_ai/features/memory/presentation/memory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeMemoryRepository repository;

  setUp(() => repository = FakeMemoryRepository());

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      screen,
      overrides: [memoryRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  group('memory', () {
    testWidgets('lists what is remembered, by kind', (
      WidgetTester tester,
    ) async {
      await pump(tester, const MemoryScreen());
      expect(find.text('onam = kontakt «Ona ❤️»'), findsOneWidget);
      expect(find.text('Kontakt'), findsOneWidget);
      expect(find.text('Afzallik'), findsOneWidget);
    });

    testWidgets('forgets one, then everything after asking', (
      WidgetTester tester,
    ) async {
      await pump(tester, const MemoryScreen());
      await tap(tester, 'memory-forget-m1');
      expect(repository.calls, contains('forget:m1'));
      expect(find.text('onam = kontakt «Ona ❤️»'), findsNothing);
      expect(find.text('Unutildi.'), findsOneWidget);

      await tap(tester, 'memory-forget-all');
      expect(find.text('Hammasi unutilsinmi?'), findsOneWidget);
      await tap(tester, 'memory-forget-all-confirm');
      expect(repository.calls, contains('forgetAll'));
      expect(find.byKey(const Key('memory-empty')), findsOneWidget);
    });

    testWidgets('a failed load can be retried; a failed delete says why', (
      WidgetTester tester,
    ) async {
      repository.failure = const NetworkFailure();
      await pump(tester, const MemoryScreen());
      expect(find.byKey(const Key('memory-error')), findsOneWidget);
      repository.failure = null;
      await tap(tester, 'memory-retry');
      expect(find.text('Telegram afzal'), findsOneWidget);

      repository.failure = const NetworkFailure();
      await tap(tester, 'memory-forget-m2');
      expect(find.text('Internet aloqasini tekshiring'), findsOneWidget);
      expect(find.text('Telegram afzal'), findsOneWidget);
    });

    testWidgets('nothing yet says how to teach it', (
      WidgetTester tester,
    ) async {
      repository.entries = <MemoryEntry>[];
      await pump(tester, const MemoryScreen());
      expect(find.byKey(const Key('memory-empty')), findsOneWidget);
      expect(find.byKey(const Key('memory-forget-all')), findsNothing);
    });
  });

  group('history', () {
    testWidgets('lists tasks with what was said and how they ended', (
      WidgetTester tester,
    ) async {
      await pump(tester, const HistoryScreen());
      expect(find.text('Onamga yoz'), findsOneWidget);
      expect(find.textContaining('Bajarildi · Yozdim'), findsOneWidget);
      expect(find.textContaining('To‘xtatildi'), findsOneWidget);
      expect(find.byKey(const Key('history-more')), findsNothing);
    });

    testWidgets('loads the next page', (WidgetTester tester) async {
      repository.pages.add(<PastTask>[
        PastTask(
          id: 't3',
          title: null,
          status: PastTaskStatus.failed,
          command: null,
          reply: null,
          createdAt: DateTime(2026, 10, 1),
        ),
      ]);
      await pump(tester, const HistoryScreen());
      await tap(tester, 'history-more');
      expect(repository.calls.last, startsWith('history:2026-10-16T08:00'));
      expect(find.text('—'), findsOneWidget);
      expect(find.byKey(const Key('history-more')), findsNothing);
    });

    testWidgets('deletes one task, then clears all after asking', (
      WidgetTester tester,
    ) async {
      await pump(tester, const HistoryScreen());
      await tap(tester, 'history-delete-t1');
      expect(repository.calls, contains('removeTask:t1'));
      expect(find.text('Onamga yoz'), findsNothing);

      await tap(tester, 'history-clear');
      await tap(tester, 'history-clear-confirm');
      expect(repository.calls, contains('clearHistory'));
      expect(find.byKey(const Key('history-empty')), findsOneWidget);
    });

    testWidgets('a failed load can be retried', (WidgetTester tester) async {
      repository.failure = const NetworkFailure();
      await pump(tester, const HistoryScreen());
      expect(find.byKey(const Key('history-error')), findsOneWidget);
      repository.failure = null;
      await tap(tester, 'history-retry');
      expect(find.text('Onamga yoz'), findsOneWidget);
    });
  });
}
