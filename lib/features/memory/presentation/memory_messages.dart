import '../../../app/l10n/app_localizations.dart';
import '../../../core/errors/failure.dart';

/// The sentence for a failed memory or history call.
String memoryFailureMessage(AppLocalizations l10n, Object error) {
  return switch (error) {
    NetworkFailure() => l10n.errorNetwork,
    ServerFailure(:final code, :final statusCode) => l10n.errorServer(
      code.json ?? 'HTTP ${statusCode ?? '?'}',
    ),
    _ => l10n.errorUnexpected,
  };
}
