import 'package:dio/dio.dart';

import '../api/generated/models/error_code.dart';
import '../api/generated/models/error_response_dto.dart';
import '../errors/failure.dart';

/// Turns anything a Dio call can throw into a [Failure].
Failure mapToFailure(Object error) {
  if (error is Failure) return error;
  if (error is! DioException) return UnexpectedFailure(error);

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      return _serverFailure(error.response);
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return UnexpectedFailure(error.error ?? error);
  }
}

ServerFailure _serverFailure(Response<Object?>? response) {
  final int? status = response?.statusCode;
  final Object? data = response?.data;
  if (data is Map<String, Object?>) {
    try {
      final ErrorResponseDto body = ErrorResponseDto.fromJson(data);
      return ServerFailure(
        code: body.error.code,
        statusCode: status,
        requestId: body.error.requestId,
      );
    } on Object {
      // Not our error shape (a proxy's HTML page, a truncated body) — fall through.
    }
  }
  return ServerFailure(
    code: ErrorCode.$unknown,
    statusCode: status,
    requestId: response?.headers.value(requestIdHeader),
  );
}

const String requestIdHeader = 'x-request-id';
