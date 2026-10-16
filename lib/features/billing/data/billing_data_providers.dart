import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../core/api/generated/clients/billing_api.dart';
import '../domain/billing.dart';
import 'billing_repository_impl.dart';

final Provider<BillingRepository> billingRepositoryProvider =
    Provider<BillingRepository>(
      (Ref ref) => BillingRepositoryImpl(BillingApi(ref.watch(dioProvider))),
    );

/// Opens a payment page; false when nothing could open it.
typedef PaymentPageOpener = Future<bool> Function(Uri url);

/// Custom Tabs (SOW 07 §5): the provider's page over the app, with its own
/// address bar, so the user sees whose page takes the card.
final Provider<PaymentPageOpener> paymentPageOpenerProvider =
    Provider<PaymentPageOpener>(
      (Ref ref) =>
          (Uri url) => launchUrl(url, mode: LaunchMode.inAppBrowserView),
    );
