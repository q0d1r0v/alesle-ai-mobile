import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/alesle_orb.dart';
import '../../../app/widgets/capsule_button.dart';
import '../data/billing_data_providers.dart';
import '../domain/billing.dart';
import 'billing_providers.dart';

enum _Phase { checking, paid, notPaid, waiting }

/// "Checking the payment" (EC-10): asks the server until the provider's
/// confirmation arrives, also when the user comes back from the payment page
/// or a payment link opens the app.
class PaymentStatusScreen extends ConsumerStatefulWidget {
  const PaymentStatusScreen({
    required this.paymentId,
    super.key,
    this.interval = const Duration(seconds: 2),
    this.timeout = const Duration(minutes: 2),
  });

  final String paymentId;
  final Duration interval;
  final Duration timeout;

  @override
  ConsumerState<PaymentStatusScreen> createState() =>
      _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends ConsumerState<PaymentStatusScreen> {
  _Phase _phase = _Phase.checking;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (_phase == _Phase.waiting) unawaited(_check());
      },
    );
    unawaited(_check());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() => _phase = _Phase.checking);
    final BillingRepository repository = ref.read(billingRepositoryProvider);
    final PaymentResult result = await waitForPayment(
      () => repository.payment(widget.paymentId),
      interval: widget.interval,
      timeout: widget.timeout,
      cancelled: () => !mounted,
    );
    if (!mounted) return;
    if (result == PaymentResult.paid) ref.invalidate(billingOverviewProvider);
    setState(
      () => _phase = switch (result) {
        PaymentResult.paid => _Phase.paid,
        PaymentResult.notPaid => _Phase.notPaid,
        PaymentResult.waiting => _Phase.waiting,
      },
    );
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.plan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    final (OrbState orb, String title, String body) = switch (_phase) {
      _Phase.checking => (
        OrbState.working,
        l10n.billingChecking,
        l10n.billingCheckingBody,
      ),
      _Phase.paid => (OrbState.done, l10n.billingPaid, l10n.billingPaidBody),
      _Phase.notPaid => (
        OrbState.notDone,
        l10n.billingNotPaid,
        l10n.billingNotPaidBody,
      ),
      _Phase.waiting => (
        OrbState.idle,
        l10n.billingStillWaiting,
        l10n.billingStillWaitingBody,
      ),
    };
    // Leaving while checking is fine: the plan switches on by itself.
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AlesleOrb(state: orb, size: 140),
                        const SizedBox(height: 28),
                        Text(
                          title,
                          key: const Key('payment-title'),
                          style: text.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          body,
                          style: text.bodyLarge?.copyWith(
                            color: AlesleColors.text2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ...switch (_phase) {
                _Phase.checking => <Widget>[],
                _Phase.paid => <Widget>[
                  CapsuleButton(
                    key: const Key('payment-done'),
                    label: l10n.commonDone,
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ],
                _Phase.notPaid => <Widget>[
                  CapsuleButton(
                    key: const Key('payment-retry'),
                    label: l10n.commonRetry,
                    onPressed: _back,
                  ),
                ],
                _Phase.waiting => <Widget>[
                  CapsuleButton(
                    key: const Key('payment-check-again'),
                    label: l10n.billingCheckAgain,
                    onPressed: () => unawaited(_check()),
                  ),
                  const SizedBox(height: 8),
                  CapsuleButton(
                    key: const Key('payment-later'),
                    label: l10n.commonLater,
                    style: CapsuleStyle.text,
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }
}
