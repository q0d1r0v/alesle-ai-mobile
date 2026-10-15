import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:alesle_ai/features/home/domain/server_health.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeHealthRepository health;
  late FakeAgentRepository agent;

  setUp(() {
    health = FakeHealthRepository(() async => readyHealth);
    agent = FakeAgentRepository(() async => disabledAgent);
  });

  List<Override> overrides({ExecutionPolicy? policy}) => <Override>[
    healthRepositoryProvider.overrideWithValue(health),
    agentRepositoryProvider.overrideWithValue(agent),
    if (policy != null) executionPolicyProvider.overrideWithValue(policy),
  ];

  Future<void> pumpHome(WidgetTester tester, {ExecutionPolicy? policy}) async {
    await pumpLocalized(
      tester,
      const HomeScreen(),
      overrides: overrides(policy: policy),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows loading states while checks are in flight', (
    WidgetTester tester,
  ) async {
    health.next = never;
    agent.next = never;
    await pumpLocalized(tester, const HomeScreen(), overrides: overrides());
    await tester.pump();

    expect(find.text('Tekshirilmoqda…'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the server as ready', (WidgetTester tester) async {
    await pumpHome(tester);
    expect(find.text('Ishlayapti'), findsOneWidget);
  });

  testWidgets('shows unavailable when a dependency is down, and retries', (
    WidgetTester tester,
  ) async {
    health.next = () async => const ServerHealth(
      dependencies: <String, String>{'database': 'up', 'redis': 'down'},
    );
    await pumpHome(tester);
    expect(find.text("Server bilan aloqa yo'q"), findsOneWidget);

    health.next = () async => readyHealth;
    await tester.tap(find.text('Qayta urinish'));
    await tester.pumpAndSettle();

    expect(find.text('Ishlayapti'), findsOneWidget);
    expect(health.calls, 2);
  });

  testWidgets('shows a network failure in plain words', (
    WidgetTester tester,
  ) async {
    health.next = () async => throw const NetworkFailure();
    await pumpHome(tester);
    expect(find.text('Internet aloqasini tekshiring'), findsOneWidget);
  });

  testWidgets('shows the server error code', (WidgetTester tester) async {
    health.next = () async => throw const ServerFailure(
      code: ErrorCode.serviceUnavailable,
      statusCode: 503,
    );
    await pumpHome(tester);
    expect(find.text('Serverda xatolik (SERVICE_UNAVAILABLE)'), findsOneWidget);
  });

  testWidgets('asks to enable accessibility and opens the settings', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester);

    expect(find.textContaining('Maxsus imkoniyatlar'), findsOneWidget);
    expect(
      find.text("Har bir muhim amal sizning tasdig'ingiz bilan bajariladi"),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('enable-accessibility-button')));
    await tester.pump();
    expect(agent.openSettingsCalls, 1);
  });

  testWidgets('shows the default confirm policy once accessibility is on', (
    WidgetTester tester,
  ) async {
    agent.next = () async => enabledAgent;
    await pumpHome(tester);

    expect(find.text('Maxsus imkoniyatlar yoqilgan'), findsOneWidget);
    expect(
      find.text("Har bir muhim amal sizning tasdig'ingiz bilan bajariladi"),
      findsOneWidget,
    );
    expect(find.byKey(const Key('enable-accessibility-button')), findsNothing);
  });

  testWidgets('shows the countdown policy when confirmation is off', (
    WidgetTester tester,
  ) async {
    agent.next = () async => enabledAgent;
    await pumpHome(tester, policy: ExecutionPolicy.countdown);

    expect(
      find.text(
        'Muhim amallar 3 soniyalik ortga sanashdan keyin bajariladi, '
        "uni bekor qilsa bo'ladi",
      ),
      findsOneWidget,
    );
  });

  testWidgets('re-reads the agent status when the app resumes', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester);
    expect(agent.statusCalls, 1);

    agent.next = () async => enabledAgent;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(agent.statusCalls, 2);
    expect(find.text('Maxsus imkoniyatlar yoqilgan'), findsOneWidget);
  });

  testWidgets('shows an agent bridge failure', (WidgetTester tester) async {
    agent.next = () async => throw const UnexpectedFailure('channel-error');
    await pumpHome(tester);
    expect(find.text('Kutilmagan xatolik'), findsOneWidget);
  });

  testWidgets('pull-to-refresh re-runs both checks', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester);
    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(health.calls, 2);
    expect(agent.statusCalls, 2);
  });

  testWidgets('pull-to-refresh completes even when a check fails', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester);
    health.next = () async => throw const NetworkFailure();
    agent.next = () async => throw const UnexpectedFailure('x');

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.byType(RefreshProgressIndicator), findsNothing);
    expect(find.text('Internet aloqasini tekshiring'), findsOneWidget);
  });
}
