import '../../../core/api/generated/clients/billing_api.dart';
import '../../../core/api/generated/models/billing_status_dto.dart';
import '../../../core/api/generated/models/billing_status_dto_providers.dart';
import '../../../core/api/generated/models/billing_status_dto_subscription_status.dart';
import '../../../core/api/generated/models/checkout_dto.dart';
import '../../../core/api/generated/models/checkout_result_dto.dart';
import '../../../core/api/generated/models/payment_dto.dart';
import '../../../core/api/generated/models/payment_provider_name.dart';
import '../../../core/api/generated/models/payment_state.dart';
import '../../../core/api/generated/models/plan_dto.dart';
import '../../../core/api/generated/models/product_kind.dart' as api;
import '../../../core/network/dio_error_mapper.dart';
import '../domain/billing.dart';

final class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl(this._api);

  final BillingApi _api;

  @override
  Future<BillingStatus> status() => _call(() async {
    final BillingStatusDto dto = await _api.billingStatus();
    return BillingStatus(
      planCode: dto.plan,
      usedPercent: dto.usedPercent.round().clamp(0, 100),
      simple: dto.simple,
      periodEnd: dto.periodEnd,
      subscription: switch (dto.subscriptionStatus) {
        null => null,
        BillingStatusDtoSubscriptionStatus.active => SubscriptionState.active,
        BillingStatusDtoSubscriptionStatus.pastDue => SubscriptionState.pastDue,
        BillingStatusDtoSubscriptionStatus.canceled ||
        BillingStatusDtoSubscriptionStatus.expired ||
        BillingStatusDtoSubscriptionStatus.$unknown =>
          SubscriptionState.canceled,
      },
      cancelAtPeriodEnd: dto.cancelAtPeriodEnd,
      methods: <PayMethod>[
        for (final BillingStatusDtoProviders provider in dto.providers)
          ?switch (provider) {
            BillingStatusDtoProviders.payme => PayMethod.payme,
            BillingStatusDtoProviders.click => PayMethod.click,
            BillingStatusDtoProviders.atmos => PayMethod.atmos,
            BillingStatusDtoProviders.$unknown => null,
          },
      ],
    );
  });

  @override
  Future<List<Product>> products() => _call(() async {
    final List<PlanDto> plans = await _api.billingPlans();
    return <Product>[
      for (final PlanDto plan in plans)
        if (plan.kind != api.ProductKind.$unknown)
          Product(
            code: plan.code,
            kind: plan.kind == api.ProductKind.pack
                ? ProductKind.pack
                : ProductKind.plan,
            priceUzs: parseSum(plan.priceUzs),
            dailyCommands: plan.dailyCommands?.toInt(),
            dailyScreenTasks: plan.dailyScreenTasks?.toInt(),
            vision: plan.vision,
            strongModel: plan.strongModel,
          ),
    ];
  });

  @override
  Future<Checkout> checkout({
    required String product,
    required PayMethod method,
    required String language,
  }) => _call(() async {
    final CheckoutResultDto result = await _api.billingCheckout(
      body: CheckoutDto(
        product: product,
        provider: switch (method) {
          PayMethod.payme => PaymentProviderName.payme,
          PayMethod.click => PaymentProviderName.click,
          PayMethod.atmos => PaymentProviderName.atmos,
        },
        language: language,
      ),
    );
    return Checkout(paymentId: result.paymentId, url: Uri.parse(result.url));
  });

  @override
  Future<PaymentResult> payment(String id) => _call(() async {
    final PaymentDto payment = await _api.billingPayment(id: id);
    return switch (payment.state) {
      PaymentState.paid => PaymentResult.paid,
      PaymentState.created ||
      PaymentState.pending ||
      PaymentState.$unknown => PaymentResult.waiting,
      PaymentState.canceled ||
      PaymentState.failed ||
      PaymentState.refunded => PaymentResult.notPaid,
    };
  });

  @override
  Future<void> cancel() => _call(_api.billingCancel);

  @override
  Future<void> resume() => _call(_api.billingResume);

  static Future<T> _call<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (error) {
      throw mapToFailure(error);
    }
  }
}
