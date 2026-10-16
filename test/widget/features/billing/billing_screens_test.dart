import 'dart:async';

import 'package:alesle_ai/app/l10n/app_localizations.dart';
import 'package:alesle_ai/app/router/app_router.dart';
import 'package:alesle_ai/app/theme/app_theme.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/billing/data/billing_data_providers.dart';
import 'package:alesle_ai/features/billing/domain/billing.dart';
import 'package:alesle_ai/features/billing/presentation/limit_screen.dart';
import 'package:alesle_ai/features/billing/presentation/pay_screen.dart';
import 'package:alesle_ai/features/billing/presentation/payment_status_screen.dart';
import 'package:alesle_ai/features/billing/presentation/plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeBillingRepository billing;
  late List<Uri> opened;
  late bool opens;

  setUp(() {
    billing = FakeBillingRepository();
    opened = <Uri>[];
    opens = true;
  });

  /// The billing routes over a stub home, starting at [location] with
  /// [below] under it (so "back" has somewhere to go).
  Future<GoRouter> pump(
    WidgetTester tester,
    String location, {
    String? below,
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final GoRouter router = GoRouter(
      initialLocation: below ?? location,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('HOME')),
        ),
        GoRoute(path: AppRoutes.plan, builder: (_, _) => const PlanScreen()),
        GoRoute(
          path: '/billing/pay/:product',
          builder: (_, GoRouterState s) =>
              PayScreen(product: s.pathParameters['product']!),
        ),
        GoRoute(
          path: '/billing/payment/:id',
          builder: (_, GoRouterState s) => PaymentStatusScreen(
            paymentId: s.pathParameters['id']!,
            interval: const Duration(milliseconds: 100),
            timeout: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: AppRoutes.limit,
          builder: (_, GoRouterState s) => LimitScreen(
            kind:
                LimitKind.fromReason(s.uri.queryParameters['reason']) ??
                LimitKind.month,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          billingRepositoryProvider.overrideWithValue(billing),
          paymentPageOpenerProvider.overrideWithValue((Uri url) async {
            opened.add(url);
            return opens;
          }),
        ],
        child: MaterialApp.router(
          theme: buildTheme(),
          locale: const Locale('uz'),
          localizationsDelegates: const <LocalizationsDelegate<Object?>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    if (below != null) {
      await tester.pump();
      unawaited(router.push(location));
    }
    await settle(tester);
    return router;
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final Finder target = find.byKey(Key(key));
    await tester.ensureVisible(target);
    await tester.pump();
    await tester.tap(target);
    await settle(tester);
  }

  group('plan', () {
    testWidgets('shows usage, plans cheapest first and the pack', (
      WidgetTester tester,
    ) async {
      await pump(tester, AppRoutes.plan);
      expect(find.byKey(const Key('plan-current')), findsOneWidget);
      expect(find.text('Bepul'), findsOneWidget);
      expect(find.text('Bu oy 40% ishlatildi'), findsOneWidget);
      expect(find.text('Ko‘proq qo‘shish · 25 000 so‘m'), findsOneWidget);
      final double pro = tester
          .getTopLeft(find.byKey(const Key('plan-pro')))
          .dy;
      final double max = tester
          .getTopLeft(find.byKey(const Key('plan-max')))
          .dy;
      expect(pro, lessThan(max));
      expect(find.text('Murakkab vazifalar uchun eng kuchli model'), findsOne);
      expect(find.byKey(const Key('plan-renewal')), findsNothing);
    });

    testWidgets('choosing a plan opens its payment methods', (
      WidgetTester tester,
    ) async {
      await pump(tester, AppRoutes.plan);
      await tap(tester, 'plan-choose-pro');
      expect(find.byType(PayScreen), findsOneWidget);
      expect(find.text('Pro · 63 000 so‘m'), findsOneWidget);
    });

    testWidgets('the pack opens its payment methods', (
      WidgetTester tester,
    ) async {
      await pump(tester, AppRoutes.plan);
      await tap(tester, 'plan-pack');
      expect(find.text('Qo‘shimcha limit · 25 000 so‘m'), findsOneWidget);
    });

    testWidgets('a paid plan can stop and resume renewing', (
      WidgetTester tester,
    ) async {
      billing.current = testBillingStatus(
        plan: 'pro',
        subscription: SubscriptionState.active,
      );
      await pump(tester, AppRoutes.plan);
      expect(find.text('Joriy tarif'), findsOneWidget);
      expect(find.text('Uzaytirish'), findsOneWidget);
      expect(find.textContaining('gacha to‘langan'), findsOneWidget);

      await tap(tester, 'plan-renewal-toggle');
      expect(find.text('Uzaytirish to‘xtatilsinmi?'), findsOneWidget);
      await tap(tester, 'plan-cancel-confirm');
      expect(billing.calls, contains('cancel'));
      expect(find.textContaining('uzaytirilmaydi'), findsOneWidget);

      await tap(tester, 'plan-renewal-toggle');
      expect(billing.calls, contains('resume'));
      expect(find.textContaining('gacha to‘langan'), findsOneWidget);
    });

    testWidgets('closing the stop dialog changes nothing', (
      WidgetTester tester,
    ) async {
      billing.current = testBillingStatus(
        plan: 'pro',
        subscription: SubscriptionState.active,
      );
      await pump(tester, AppRoutes.plan);
      await tap(tester, 'plan-renewal-toggle');
      await tester.tap(find.text('Bekor qilish'));
      await settle(tester);
      expect(billing.calls, isNot(contains('cancel')));
    });

    testWidgets('a failed renewal change says why', (
      WidgetTester tester,
    ) async {
      billing.current = testBillingStatus(
        plan: 'pro',
        subscription: SubscriptionState.active,
        cancelAtPeriodEnd: true,
      );
      await pump(tester, AppRoutes.plan);
      billing.failure = const NetworkFailure();
      await tap(tester, 'plan-renewal-toggle');
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('says when the month is used up or renewal failed', (
      WidgetTester tester,
    ) async {
      billing.current = testBillingStatus(
        usedPercent: 100,
        simple: true,
        subscription: SubscriptionState.pastDue,
      );
      await pump(tester, AppRoutes.plan);
      expect(find.byKey(const Key('plan-simple')), findsOneWidget);
      expect(find.byKey(const Key('plan-past-due')), findsOneWidget);
    });

    testWidgets('a failed load can be retried', (WidgetTester tester) async {
      billing.failure = const NetworkFailure();
      await pump(tester, AppRoutes.plan);
      expect(find.byKey(const Key('plan-error')), findsOneWidget);
      billing.failure = null;
      await tap(tester, 'plan-retry');
      expect(find.byKey(const Key('plan-current')), findsOneWidget);
    });
  });

  group('pay', () {
    testWidgets('opens the provider’s page, then waits for the payment', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pump(
        tester,
        AppRoutes.payFor('pro'),
        below: AppRoutes.plan,
      );
      expect(find.text('Payme'), findsOneWidget);
      expect(find.text('Click'), findsOneWidget);
      expect(find.text('Bank kartasi'), findsOneWidget);

      await tap(tester, 'pay-payme');
      expect(billing.calls, contains('checkout:pro:payme:uz'));
      expect(opened, <Uri>[Uri.parse('https://checkout.example/pay-1')]);
      expect(find.text('To‘lov qabul qilindi'), findsOneWidget);
      // The pay screen gave way: back goes to the plan, not to "Pay with".
      expect(find.byType(PayScreen), findsNothing);

      await tap(tester, 'payment-done');
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoutes.home,
      );
    });

    testWidgets('says so when the page cannot open', (
      WidgetTester tester,
    ) async {
      opens = false;
      await pump(tester, AppRoutes.payFor('pro'));
      await tap(tester, 'pay-click');
      expect(find.text('To‘lov sahifasini ochib bo‘lmadi.'), findsOneWidget);
      expect(find.byType(PayScreen), findsOneWidget);
    });

    testWidgets('a failed checkout says why', (WidgetTester tester) async {
      billing.checkoutFailure = const NetworkFailure();
      await pump(tester, AppRoutes.payFor('pro'));
      await tap(tester, 'pay-atmos');
      expect(find.byType(SnackBar), findsOneWidget);
      expect(opened, isEmpty);
    });

    testWidgets('without payment methods it says payment is not ready', (
      WidgetTester tester,
    ) async {
      billing.current = testBillingStatus(methods: const <PayMethod>[]);
      await pump(tester, AppRoutes.payFor('pro'));
      expect(find.byKey(const Key('pay-no-methods')), findsOneWidget);
    });

    testWidgets('a failed load can be retried', (WidgetTester tester) async {
      billing.failure = const NetworkFailure();
      await pump(tester, AppRoutes.payFor('pro'));
      expect(find.byKey(const Key('pay-error')), findsOneWidget);
      billing.failure = null;
      await tester.tap(find.text('Qayta urinish'));
      await settle(tester);
      expect(find.text('Payme'), findsOneWidget);
    });
  });

  group('payment status', () {
    testWidgets('a refused payment offers another try', (
      WidgetTester tester,
    ) async {
      billing.payments = <PaymentResult>[PaymentResult.notPaid];
      await pump(tester, AppRoutes.paymentFor('p1'), below: AppRoutes.plan);
      expect(find.text('To‘lov o‘tmadi'), findsOneWidget);
      await tap(tester, 'payment-retry');
      expect(find.byType(PlanScreen), findsOneWidget);
    });

    testWidgets('opened alone, "try again" goes to the plan', (
      WidgetTester tester,
    ) async {
      billing.payments = <PaymentResult>[PaymentResult.notPaid];
      await pump(tester, AppRoutes.paymentFor('p1'));
      await tap(tester, 'payment-retry');
      expect(find.byType(PlanScreen), findsOneWidget);
    });

    testWidgets('an unconfirmed payment can be checked again', (
      WidgetTester tester,
    ) async {
      billing.payments = <PaymentResult>[
        PaymentResult.waiting,
        PaymentResult.waiting,
        PaymentResult.waiting,
        PaymentResult.waiting,
        PaymentResult.waiting,
        PaymentResult.paid,
      ];
      await pump(tester, AppRoutes.paymentFor('p1'));
      expect(find.text('Hali tasdiqlanmadi'), findsOneWidget);
      await tap(tester, 'payment-check-again');
      expect(find.text('To‘lov qabul qilindi'), findsOneWidget);
    });

    testWidgets('"later" goes home', (WidgetTester tester) async {
      billing.payments = <PaymentResult>[PaymentResult.waiting];
      await pump(tester, AppRoutes.paymentFor('p1'));
      await tap(tester, 'payment-later');
      expect(find.text('HOME'), findsOneWidget);
    });
  });

  group('limit', () {
    testWidgets('a used-up month offers the pack, an upgrade or waiting', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        AppRoutes.limitFor('limit_reached'),
        below: AppRoutes.home,
      );
      expect(find.text('Bu oylik limit tugadi'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.byKey(const Key('limit-upgrade')), findsOneWidget);
      expect(find.textContaining('gacha kutish'), findsOneWidget);
      await tap(tester, 'limit-pack');
      expect(find.text('Qo‘shimcha limit · 25 000 so‘m'), findsOneWidget);
    });

    testWidgets('the daily cap offers an upgrade or tomorrow', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        AppRoutes.limitFor('daily_limit'),
        below: AppRoutes.home,
      );
      expect(find.text('Bugungi bepul limit tugadi'), findsOneWidget);
      expect(find.byKey(const Key('limit-pack')), findsNothing);
      expect(find.text('Ertagacha kutish'), findsOneWidget);
      await tap(tester, 'limit-upgrade');
      expect(find.byType(PlanScreen), findsOneWidget);
    });

    testWidgets('"later" and close go back', (WidgetTester tester) async {
      await pump(tester, AppRoutes.limitFor('daily_limit'), below: '/');
      await tap(tester, 'limit-later');
      expect(find.text('HOME'), findsOneWidget);

      await pump(tester, AppRoutes.limitFor('limit_reached'));
      await tap(tester, 'limit-close');
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('Max has nothing to upgrade to', (WidgetTester tester) async {
      billing.current = testBillingStatus(
        plan: 'max',
        subscription: SubscriptionState.active,
      );
      await pump(tester, AppRoutes.limitFor('limit_reached'));
      expect(find.byKey(const Key('limit-upgrade')), findsNothing);
      expect(find.byKey(const Key('limit-pack')), findsOneWidget);
    });

    testWidgets('an unknown reason counts as the month', (
      WidgetTester tester,
    ) async {
      expect(LimitKind.fromReason('stuck'), isNull);
      billing.failure = const NetworkFailure();
      await pump(tester, AppRoutes.limit);
      expect(find.text('Bu oylik limit tugadi'), findsOneWidget);
      expect(find.text('Keyinroq'), findsOneWidget);
    });
  });
}

/// The status screen's orb turns forever while checking: settle by time.
Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
