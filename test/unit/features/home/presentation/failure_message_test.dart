import 'package:alesle_ai/app/l10n/app_localizations.dart';
import 'package:alesle_ai/app/l10n/app_localizations_uz.dart';
import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/home/presentation/failure_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final AppLocalizations l10n = AppLocalizationsUz();

  test('network failures ask the user to check their connection', () {
    expect(failureMessage(l10n, const NetworkFailure()), l10n.errorNetwork);
  });

  test('server failures show the code, or the HTTP status when unknown', () {
    expect(
      failureMessage(
        l10n,
        const ServerFailure(code: ErrorCode.rateLimited, statusCode: 429),
      ),
      'Serverda xatolik (RATE_LIMITED)',
    );
    expect(
      failureMessage(
        l10n,
        const ServerFailure(code: ErrorCode.$unknown, statusCode: 502),
      ),
      'Serverda xatolik (HTTP 502)',
    );
    expect(
      failureMessage(
        l10n,
        const ServerFailure(code: ErrorCode.$unknown, statusCode: null),
      ),
      'Serverda xatolik (HTTP ?)',
    );
  });

  test('anything else is unexpected', () {
    expect(
      failureMessage(l10n, const UnexpectedFailure('x')),
      l10n.errorUnexpected,
    );
    expect(failureMessage(l10n, StateError('x')), l10n.errorUnexpected);
  });
}
