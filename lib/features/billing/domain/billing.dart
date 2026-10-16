/// Payment methods (SOW 07 §5). The app shows only those the server offers.
enum PayMethod { payme, click, atmos }

enum ProductKind { plan, pack }

/// A plan or a credit pack on sale. Users never see credits (D9): a plan is
/// described by what it allows.
final class Product {
  const Product({
    required this.code,
    required this.kind,
    required this.priceUzs,
    required this.dailyCommands,
    required this.dailyScreenTasks,
    required this.vision,
    required this.strongModel,
  });

  final String code;
  final ProductKind kind;

  /// Whole sum, from the server's decimal string.
  final int priceUzs;

  /// Commands per day; null: no daily cap.
  final int? dailyCommands;
  final int? dailyScreenTasks;
  final bool vision;
  final bool strongModel;

  bool get forSale => priceUzs > 0;
}

enum SubscriptionState { active, pastDue, canceled }

/// The user's plan this period.
final class BillingStatus {
  const BillingStatus({
    required this.planCode,
    required this.usedPercent,
    required this.simple,
    required this.periodEnd,
    required this.subscription,
    required this.cancelAtPeriodEnd,
    required this.methods,
  });

  final String planCode;

  /// 0–100 of this period's allowance.
  final int usedPercent;

  /// Allowance used up: simple commands only until [periodEnd].
  final bool simple;
  final DateTime periodEnd;

  /// Paid plan state; null on Free.
  final SubscriptionState? subscription;
  final bool cancelAtPeriodEnd;
  final List<PayMethod> methods;

  UsageLevel get level => usageLevel(usedPercent, simple: simple);
}

enum UsageLevel { normal, high, out }

/// High from 80 % (the reminder), out at 100 % or in simple mode.
UsageLevel usageLevel(int percent, {bool simple = false}) {
  if (simple || percent >= 100) return UsageLevel.out;
  if (percent >= 80) return UsageLevel.high;
  return UsageLevel.normal;
}

/// Identifies the usage notice due now, so each is shown once per period;
/// null when none is due.
String? usageNoticeKey(BillingStatus status) => switch (status.level) {
  UsageLevel.normal => null,
  UsageLevel.high => '${status.periodEnd.toUtc().toIso8601String()}:80',
  UsageLevel.out => '${status.periodEnd.toUtc().toIso8601String()}:100',
};

/// "63 000": groups of three, split by a no-break space.
String formatSum(int amount) {
  final String digits = amount.abs().toString();
  final StringBuffer out = StringBuffer(amount < 0 ? '-' : '');
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(' ');
    out.write(digits[i]);
  }
  return out.toString();
}

/// Whole sum from a decimal string ("63000.00"); 0 when unreadable.
int parseSum(String decimal) => num.tryParse(decimal)?.floor() ?? 0;

final class Checkout {
  const Checkout({required this.paymentId, required this.url});

  final String paymentId;

  /// The provider's page, opened in Custom Tabs.
  final Uri url;
}

enum PaymentResult { waiting, paid, notPaid }

/// Throws a `Failure` from core/errors.
abstract interface class BillingRepository {
  Future<BillingStatus> status();

  Future<List<Product>> products();

  Future<Checkout> checkout({
    required String product,
    required PayMethod method,
    required String language,
  });

  Future<PaymentResult> payment(String id);

  /// Stops renewing; the plan lasts until the period ends.
  Future<void> cancel();

  Future<void> resume();
}

/// Asks about a payment until it is final or about [timeout] of asking has
/// passed (EC-10: the provider may confirm a little after the user comes
/// back). Errors while asking count as "still waiting".
Future<PaymentResult> waitForPayment(
  Future<PaymentResult> Function() check, {
  Duration interval = const Duration(seconds: 2),
  Duration timeout = const Duration(minutes: 2),
  Future<void> Function(Duration)? sleep,
  bool Function()? cancelled,
}) async {
  final Future<void> Function(Duration) wait =
      sleep ?? (Duration d) => Future<void>.delayed(d);
  // Counted in tries, not by the wall clock: the same in tests and on a
  // phone that sleeps.
  final int tries = interval <= Duration.zero
      ? 1
      : (timeout.inMicroseconds / interval.inMicroseconds).ceil() + 1;
  for (int i = 0; i < tries; i++) {
    if (cancelled?.call() ?? false) return PaymentResult.waiting;
    if (i > 0) await wait(interval);
    if (cancelled?.call() ?? false) return PaymentResult.waiting;
    try {
      final PaymentResult result = await check();
      if (result != PaymentResult.waiting) return result;
    } on Object {
      // Offline for a moment: keep asking.
    }
  }
  return PaymentResult.waiting;
}

/// The payment to check from `https://alesle.ai/billing/return?payment=<id>`,
/// where the provider's page sends the user back; null for any other link.
String? paymentFromReturnLink(Uri uri) {
  if (uri.scheme != 'https' || uri.host != 'alesle.ai') return null;
  if (uri.path != '/billing/return') return null;
  final String? id = uri.queryParameters['payment'];
  return id == null || id.isEmpty ? null : id;
}
