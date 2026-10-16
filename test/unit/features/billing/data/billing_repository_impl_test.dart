import 'package:alesle_ai/core/api/generated/clients/billing_api.dart';
import 'package:alesle_ai/core/api/generated/models/billing_status_dto.dart';
import 'package:alesle_ai/core/api/generated/models/billing_status_dto_providers.dart';
import 'package:alesle_ai/core/api/generated/models/billing_status_dto_subscription_status.dart';
import 'package:alesle_ai/core/api/generated/models/checkout_dto.dart';
import 'package:alesle_ai/core/api/generated/models/checkout_result_dto.dart';
import 'package:alesle_ai/core/api/generated/models/payment_dto.dart';
import 'package:alesle_ai/core/api/generated/models/payment_provider_name.dart';
import 'package:alesle_ai/core/api/generated/models/payment_state.dart';
import 'package:alesle_ai/core/api/generated/models/plan_dto.dart';
import 'package:alesle_ai/core/api/generated/models/product_kind.dart' as api;
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/billing/data/billing_repository_impl.dart';
import 'package:alesle_ai/features/billing/domain/billing.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBillingApi extends Mock implements BillingApi {}

BillingStatusDto _status({
  BillingStatusDtoSubscriptionStatus? subscription,
  num used = 42.4,
}) => BillingStatusDto(
  plan: 'pro',
  usedPercent: used,
  simple: false,
  periodEnd: DateTime.utc(2026, 11, 16),
  subscriptionStatus: subscription,
  cancelAtPeriodEnd: true,
  providers: BillingStatusDtoProviders.values,
);

void main() {
  late _MockBillingApi api_;
  late BillingRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const CheckoutDto(
        product: 'pro',
        provider: PaymentProviderName.payme,
        language: 'uz',
      ),
    );
  });

  setUp(() {
    api_ = _MockBillingApi();
    repository = BillingRepositoryImpl(api_);
  });

  test('maps the status, dropping unknown payment methods', () async {
    when(api_.billingStatus).thenAnswer(
      (_) async =>
          _status(subscription: BillingStatusDtoSubscriptionStatus.active),
    );
    final BillingStatus status = await repository.status();
    expect(status.planCode, 'pro');
    expect(status.usedPercent, 42);
    expect(status.subscription, SubscriptionState.active);
    expect(status.cancelAtPeriodEnd, isTrue);
    expect(status.methods, PayMethod.values);
  });

  test('maps every subscription state', () async {
    final Map<BillingStatusDtoSubscriptionStatus?, SubscriptionState?>
    cases = <BillingStatusDtoSubscriptionStatus?, SubscriptionState?>{
      null: null,
      BillingStatusDtoSubscriptionStatus.pastDue: SubscriptionState.pastDue,
      BillingStatusDtoSubscriptionStatus.canceled: SubscriptionState.canceled,
      BillingStatusDtoSubscriptionStatus.expired: SubscriptionState.canceled,
      BillingStatusDtoSubscriptionStatus.$unknown: SubscriptionState.canceled,
    };
    for (final MapEntry<BillingStatusDtoSubscriptionStatus?, SubscriptionState?>
        entry
        in cases.entries) {
      when(api_.billingStatus)
          .thenAnswer((_) async => _status(subscription: entry.key, used: 140));
      final BillingStatus status = await repository.status();
      expect(status.subscription, entry.value);
      expect(status.usedPercent, 100);
    }
  });

  test('maps products, skipping unknown kinds', () async {
    when(api_.billingPlans).thenAnswer(
      (_) async => <PlanDto>[
        const PlanDto(
          code: 'free',
          kind: api.ProductKind.plan,
          priceUzs: '0.00',
          priceUsd: '0.00',
          dailyCommands: 20,
          dailyScreenTasks: 3,
          vision: false,
          strongModel: false,
        ),
        const PlanDto(
          code: 'pack_500',
          kind: api.ProductKind.pack,
          priceUzs: '25000.00',
          priceUsd: '1.99',
          dailyCommands: null,
          dailyScreenTasks: null,
          vision: false,
          strongModel: false,
        ),
        const PlanDto(
          code: 'later',
          kind: api.ProductKind.$unknown,
          priceUzs: '1',
          priceUsd: '1',
          dailyCommands: null,
          dailyScreenTasks: null,
          vision: false,
          strongModel: false,
        ),
      ],
    );
    final List<Product> products = await repository.products();
    expect(products.map((Product p) => p.code), <String>['free', 'pack_500']);
    expect(products.first.dailyCommands, 20);
    expect(products.last.kind, ProductKind.pack);
    expect(products.last.priceUzs, 25000);
  });

  test('starts a checkout with each method', () async {
    when(() => api_.billingCheckout(body: any(named: 'body'))).thenAnswer(
      (_) async => const CheckoutResultDto(
        paymentId: 'p1',
        url: 'https://checkout.paycom.uz/abc',
      ),
    );
    for (final PayMethod method in PayMethod.values) {
      final Checkout checkout = await repository.checkout(
        product: 'pro',
        method: method,
        language: 'ru',
      );
      expect(checkout.paymentId, 'p1');
      expect(checkout.url.host, 'checkout.paycom.uz');
    }
    final List<Object?> bodies = verify(
      () => api_.billingCheckout(body: captureAny(named: 'body')),
    ).captured;
    expect(
      bodies.cast<CheckoutDto>().map((CheckoutDto b) => b.provider),
      <PaymentProviderName>[
        PaymentProviderName.payme,
        PaymentProviderName.click,
        PaymentProviderName.atmos,
      ],
    );
  });

  test('maps every payment state', () async {
    final Map<PaymentState, PaymentResult> cases =
        <PaymentState, PaymentResult>{
          PaymentState.created: PaymentResult.waiting,
          PaymentState.pending: PaymentResult.waiting,
          PaymentState.$unknown: PaymentResult.waiting,
          PaymentState.paid: PaymentResult.paid,
          PaymentState.canceled: PaymentResult.notPaid,
          PaymentState.failed: PaymentResult.notPaid,
          PaymentState.refunded: PaymentResult.notPaid,
        };
    for (final MapEntry<PaymentState, PaymentResult> entry in cases.entries) {
      when(() => api_.billingPayment(id: 'p1')).thenAnswer(
        (_) async => PaymentDto(id: 'p1', state: entry.key, product: 'pro'),
      );
      expect(await repository.payment('p1'), entry.value);
    }
  });

  test('cancels and resumes renewal', () async {
    when(api_.billingCancel).thenAnswer((_) async {});
    when(api_.billingResume).thenAnswer((_) async {});
    await repository.cancel();
    await repository.resume();
    verify(api_.billingCancel).called(1);
    verify(api_.billingResume).called(1);
  });

  test('turns transport errors into failures', () async {
    when(api_.billingStatus).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/v1/billing/status'),
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(repository.status(), throwsA(isA<NetworkFailure>()));
  });
}
