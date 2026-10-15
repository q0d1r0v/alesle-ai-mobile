import '../api/generated/models/error_code.dart';

/// Every way a call to the outside world can fail, as the UI needs to tell
/// them apart. Repositories throw these; nothing else crosses into widgets.
sealed class Failure implements Exception {
  const Failure();
}

/// No response at all: offline, DNS, timeout, TLS.
final class NetworkFailure extends Failure {
  const NetworkFailure();

  @override
  String toString() => 'NetworkFailure';
}

/// The server answered with an error body (or an unparseable error).
///
/// [code] is the backend's machine-readable code; the UI branches on it,
/// never on a message. [requestId] lets support find the server log line.
final class ServerFailure extends Failure {
  const ServerFailure({
    required this.code,
    required this.statusCode,
    this.requestId,
  });

  final ErrorCode code;
  final int? statusCode;
  final String? requestId;

  @override
  String toString() =>
      'ServerFailure(code: ${code.json ?? 'unknown'}, status: $statusCode, requestId: $requestId)';
}

/// A bug on our side (bad JSON shape, unexpected exception).
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.cause);

  final Object cause;

  @override
  String toString() => 'UnexpectedFailure($cause)';
}
