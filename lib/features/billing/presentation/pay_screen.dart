import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/grouped_card.dart';
import '../data/billing_data_providers.dart';
import '../domain/billing.dart';
import 'billing_messages.dart';
import 'billing_providers.dart';

/// "Pay with": the payment methods the server offers for [product]. The
/// provider's page opens in Custom Tabs; this screen then gives way to the
/// payment's status.
class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({required this.product, super.key});

  final String product;

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  bool _busy = false;

  Future<void> _pay(PayMethod method) async {
    if (_busy) return;
    setState(() => _busy = true);
    final AppLocalizations l10n = context.l10n;
    final String language = Localizations.localeOf(context).languageCode;
    final BillingRepository repository = ref.read(billingRepositoryProvider);
    final PaymentPageOpener open = ref.read(paymentPageOpenerProvider);
    try {
      final Checkout checkout = await repository.checkout(
        product: widget.product,
        method: method,
        language: language,
      );
      final bool opened = await open(checkout.url);
      if (!mounted) return;
      if (!opened) {
        _say(l10n.billingPageNotOpened);
        return;
      }
      context.pushReplacement(AppRoutes.paymentFor(checkout.paymentId));
    } on Object catch (error) {
      if (mounted) _say(billingFailureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _say(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    final AsyncValue<BillingOverview> overview = ref.watch(
      billingOverviewProvider,
    );
    return Scaffold(
      appBar: AppBar(),
      body: switch (overview) {
        AsyncValue<BillingOverview>(:final BillingOverview value)
            when overview.hasValue =>
          ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              32 + MediaQuery.paddingOf(context).bottom,
            ),
            children: <Widget>[
              Text(
                l10n.billingPayTitle,
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              if (value.product(widget.product) case final Product product)
                Text(
                  '${productName(l10n, product.code)} · '
                  '${l10n.billingPrice(formatSum(product.priceUzs))}',
                  key: const Key('pay-summary'),
                  style: text.bodyLarge?.copyWith(color: AlesleColors.text2),
                ),
              const SizedBox(height: 20),
              if (value.status.methods.isEmpty)
                Text(
                  l10n.billingNoMethods,
                  key: const Key('pay-no-methods'),
                  style: text.bodyLarge,
                )
              else
                AlesleGroup(
                  children: <Widget>[
                    for (final PayMethod method in value.status.methods)
                      ListTile(
                        key: Key('pay-${method.name}'),
                        enabled: !_busy,
                        leading: Icon(_icon(method)),
                        title: Text(methodName(l10n, method)),
                        subtitle: method == PayMethod.atmos
                            ? const Text('Uzcard, Humo, Visa, Mastercard')
                            : null,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => unawaited(_pay(method)),
                      ),
                  ],
                ),
              const SizedBox(height: 24),
              if (_busy) const Center(child: CircularProgressIndicator()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: AlesleColors.text2,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l10n.billingSecure,
                      style: text.bodySmall?.copyWith(
                        color: AlesleColors.text2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        AsyncValue<BillingOverview>(:final Object error)
            when overview.hasError =>
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  billingFailureMessage(l10n, error),
                  key: const Key('pay-error'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.invalidate(billingOverviewProvider),
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  static IconData _icon(PayMethod method) => switch (method) {
    PayMethod.payme => Icons.account_balance_wallet_outlined,
    PayMethod.click => Icons.touch_app_outlined,
    PayMethod.atmos => Icons.credit_card_rounded,
  };
}
