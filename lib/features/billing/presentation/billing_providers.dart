import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/billing_data_providers.dart';
import '../domain/billing.dart';

/// The user's plan and what is on sale, read together.
final class BillingOverview {
  const BillingOverview({required this.status, required this.products});

  final BillingStatus status;
  final List<Product> products;

  Product? product(String code) {
    for (final Product p in products) {
      if (p.code == code) return p;
    }
    return null;
  }

  /// Paid plans, cheapest first.
  List<Product> get plans =>
      products
          .where((Product p) => p.kind == ProductKind.plan && p.forSale)
          .toList()
        ..sort((Product a, Product b) => a.priceUzs.compareTo(b.priceUzs));

  /// The cheapest pack, if any is on sale.
  Product? get pack {
    final List<Product> packs =
        products
            .where((Product p) => p.kind == ProductKind.pack && p.forSale)
            .toList()
          ..sort((Product a, Product b) => a.priceUzs.compareTo(b.priceUzs));
    return packs.isEmpty ? null : packs.first;
  }
}

/// Re-read after a payment or a plan change (`ref.invalidate`).
final FutureProvider<BillingOverview> billingOverviewProvider =
    FutureProvider.autoDispose<BillingOverview>((Ref ref) async {
      final BillingRepository repository = ref.watch(billingRepositoryProvider);
      // One after the other: a record's `.wait` wraps errors, and the
      // screens show the Failure itself.
      final BillingStatus status = await repository.status();
      final List<Product> products = await repository.products();
      return BillingOverview(status: status, products: products);
    });
