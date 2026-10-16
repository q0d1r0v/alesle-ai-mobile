import 'package:alesle_ai/features/billing/domain/billing.dart';
import 'package:flutter_test/flutter_test.dart';

BillingStatus _status({int percent = 0, bool simple = false}) => BillingStatus(
  planCode: 'free',
  usedPercent: percent,
  simple: simple,
  periodEnd: DateTime.utc(2026, 11, 16, 7),
  subscription: null,
  cancelAtPeriodEnd: false,
  methods: const <PayMethod>[],
);

void main() {
  group('usage', () {
    test('is high from 80 % and out at 100 % or in simple mode', () {
      expect(usageLevel(79), UsageLevel.normal);
      expect(usageLevel(80), UsageLevel.high);
      expect(usageLevel(99), UsageLevel.high);
      expect(usageLevel(100), UsageLevel.out);
      expect(usageLevel(10, simple: true), UsageLevel.out);
      expect(_status(percent: 85).level, UsageLevel.high);
    });

    test('notices are keyed by period and level', () {
      expect(usageNoticeKey(_status(percent: 50)), isNull);
      expect(
        usageNoticeKey(_status(percent: 81)),
        '2026-11-16T07:00:00.000Z:80',
      );
      expect(
        usageNoticeKey(_status(percent: 20, simple: true)),
        '2026-11-16T07:00:00.000Z:100',
      );
    });
  });

  test('sums are grouped by three with a no-break space', () {
    expect(formatSum(0), '0');
    expect(formatSum(500), '500');
    expect(formatSum(25000), '25 000');
    expect(formatSum(1640000), '1 640 000');
    expect(formatSum(-63000), '-63 000');
    expect(parseSum('63000.00'), 63000);
    expect(parseSum('25000'), 25000);
    expect(parseSum('x'), 0);
  });

  test('only priced products are for sale', () {
    const Product free = Product(
      code: 'free',
      kind: ProductKind.plan,
      priceUzs: 0,
      dailyCommands: 20,
      dailyScreenTasks: 3,
      vision: false,
      strongModel: false,
    );
    expect(free.forSale, isFalse);
  });

  test('reads the payment page’s way back, and nothing else', () {
    expect(
      paymentFromReturnLink(
        Uri.parse('https://alesle.ai/billing/return?payment=p1'),
      ),
      'p1',
    );
    for (final String other in <String>[
      'https://alesle.ai/billing/return',
      'https://alesle.ai/billing/return?payment=',
      'https://alesle.ai/auth/link?payment=p1',
      'https://evil.example/billing/return?payment=p1',
      'http://alesle.ai/billing/return?payment=p1',
    ]) {
      expect(paymentFromReturnLink(Uri.parse(other)), isNull, reason: other);
    }
  });

  group('waitForPayment', () {
    late List<Duration> slept;

    setUp(() => slept = <Duration>[]);

    Future<void> sleep(Duration d) async => slept.add(d);

    test('asks until the payment is final', () async {
      final List<PaymentResult> answers = <PaymentResult>[
        PaymentResult.waiting,
        PaymentResult.waiting,
        PaymentResult.paid,
      ];
      final PaymentResult result = await waitForPayment(
        () async => answers.removeAt(0),
        sleep: sleep,
      );
      expect(result, PaymentResult.paid);
      expect(slept, hasLength(2));
    });

    test('reports a refused payment at once', () async {
      expect(
        await waitForPayment(() async => PaymentResult.notPaid, sleep: sleep),
        PaymentResult.notPaid,
      );
      expect(slept, isEmpty);
    });

    test('keeps asking through errors, then gives up waiting', () async {
      int asked = 0;
      final PaymentResult result = await waitForPayment(
        () async {
          asked++;
          if (asked.isOdd) throw StateError('offline');
          return PaymentResult.waiting;
        },
        interval: const Duration(seconds: 10),
        timeout: const Duration(seconds: 30),
        sleep: sleep,
      );
      expect(result, PaymentResult.waiting);
      expect(asked, 4);
    });

    test('asks once when there is no interval', () async {
      int asked = 0;
      await waitForPayment(() async {
        asked++;
        return PaymentResult.waiting;
      }, interval: Duration.zero);
      expect(asked, 1);
    });

    test('stops when cancelled', () async {
      int asked = 0;
      bool gone = false;
      final PaymentResult result = await waitForPayment(
        () async {
          asked++;
          gone = true;
          return PaymentResult.waiting;
        },
        sleep: sleep,
        cancelled: () => gone,
      );
      expect(result, PaymentResult.waiting);
      expect(asked, 1);
    });

    test('uses real delays by default', () async {
      final PaymentResult result = await waitForPayment(
        () async => PaymentResult.waiting,
        interval: const Duration(milliseconds: 1),
        timeout: const Duration(milliseconds: 5),
      );
      expect(result, PaymentResult.waiting);
    });
  });
}
