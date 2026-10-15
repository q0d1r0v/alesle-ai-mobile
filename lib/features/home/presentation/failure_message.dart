import '../../../app/l10n/app_localizations.dart';
import '../../../core/errors/failure.dart';

/// The sentence a user sees for a [Failure]. Branches on type and code only.
String failureMessage(AppLocalizations l10n, Object error) {
  return switch (error) {
    NetworkFailure() => l10n.errorNetwork,
    ServerFailure(:final code, :final statusCode) => l10n.errorServer(
      code.json ?? 'HTTP ${statusCode ?? '?'}',
    ),
    _ => l10n.errorUnexpected,
  };
}
