import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_session.dart';
import '../core/storage/app_settings.dart';
import '../features/auth/data/auth_data_providers.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/auth_messages.dart';
import '../features/billing/domain/billing.dart';
import '../features/settings/data/settings_data_providers.dart';
import '../features/settings/domain/account.dart';
import 'bootstrap/core_providers.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';

/// Links the app is opened with (App Links); tests replace it.
final Provider<Stream<Uri>> incomingLinksProvider = Provider<Stream<Uri>>((
  Ref ref,
) {
  final AppLinks links = AppLinks();
  // The link that started the app, then any that arrive while it runs.
  return links.uriLinkStream;
});

/// Shows messages from outside any screen (an opened email link).
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// App-wide account upkeep: opens sign-in and confirmation links from emails
/// (EC-AU-1) and the payment page's way back (SOW 07 §5), and after a sign-in brings this phone and the account in line.
class AccountLinks extends ConsumerStatefulWidget {
  const AccountLinks({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AccountLinks> createState() => _AccountLinksState();
}

class _AccountLinksState extends ConsumerState<AccountLinks> {
  StreamSubscription<Uri>? _links;

  @override
  void initState() {
    super.initState();
    _links = ref
        .read(incomingLinksProvider)
        .listen((Uri uri) => unawaited(_open(uri)));
  }

  @override
  void dispose() {
    unawaited(_links?.cancel());
    super.dispose();
  }

  Future<void> _open(Uri uri) async {
    if (paymentFromReturnLink(uri) case final String payment) {
      _openPayment(payment);
      return;
    }
    final EmailLink? link = EmailLink.parse(uri);
    if (link == null) return;
    final AuthRepository auth = ref.read(authRepositoryProvider);
    try {
      switch (link) {
        case SignInLink(:final String token):
          await auth.signInWithMagicLink(token);
        case VerifyLink(:final String token):
          await auth.verifyEmail(token);
          _say((AppLocalizations l10n) => l10n.emailVerified);
      }
    } on Object catch (error) {
      _say((AppLocalizations l10n) => authFailureMessage(l10n, error));
    }
  }

  /// Shows the payment's status, unless it is already on screen (the status
  /// screen opened when the payment page did).
  void _openPayment(String payment) {
    final GoRouter router = ref.read(routerProvider);
    final String path = AppRoutes.paymentFor(payment);
    if (router.routerDelegate.currentConfiguration.uri.path == path) return;
    unawaited(router.push(path));
  }

  void _say(String Function(AppLocalizations l10n) message) {
    final ScaffoldMessengerState? messenger = appMessengerKey.currentState;
    // This widget sits under MaterialApp's Localizations; the messenger may not.
    final AppLocalizations? l10n = mounted
        ? Localizations.of<AppLocalizations>(context, AppLocalizations)
        : null;
    if (messenger == null || l10n == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message(l10n))));
  }

  /// The language chosen in onboarding goes to the account; the account's
  /// confirmation setting (AC-APP-4) comes to the phone.
  Future<void> _syncAfterSignIn() async {
    final AccountRepository account = ref.read(accountRepositoryProvider);
    final String? language = ref.read(appSettingsProvider).language;
    try {
      final Profile profile = language == null
          ? await account.profile()
          : await account.update(language: language);
      await ref
          .read(appSettingsProvider.notifier)
          .update(
            (AppSettings settings) => settings.copyWith(
              confirmSensitiveActions: profile.confirmSensitiveActions,
              language: profile.language,
            ),
          );
    } on Object {
      // Offline: the local copy stays; settings syncs again when opened.
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthSession?>(sessionProvider, (
      AuthSession? before,
      AuthSession? now,
    ) {
      if (before == null && now != null) unawaited(_syncAfterSignIn());
    });
    return widget.child;
  }
}
