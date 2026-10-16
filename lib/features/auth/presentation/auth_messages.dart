import '../../../app/l10n/app_localizations.dart';
import '../../../core/api/generated/models/error_code.dart';
import '../../../core/errors/failure.dart';

/// The sentence for a failed sign-in. Branches on type and code only.
String authFailureMessage(AppLocalizations l10n, Object error) {
  return switch (error) {
    NetworkFailure() => l10n.errorNetwork,
    ServerFailure(code: ErrorCode.invalidCredentials) =>
      l10n.authInvalidCredentials,
    ServerFailure(code: ErrorCode.emailTaken) => l10n.authEmailTaken,
    ServerFailure(code: ErrorCode.linkInvalid) => l10n.authLinkInvalid,
    ServerFailure(code: ErrorCode.googleTokenInvalid) ||
    ServerFailure(
      code: ErrorCode.signInMethodUnavailable,
    ) => l10n.authGoogleFailed,
    ServerFailure(code: ErrorCode.sessionExpired) => l10n.authSessionExpired,
    ServerFailure(code: ErrorCode.rateLimited) => l10n.authTooMany,
    ServerFailure(:final code, :final statusCode) => l10n.errorServer(
      code.json ?? 'HTTP ${statusCode ?? '?'}',
    ),
    _ => l10n.errorUnexpected,
  };
}
