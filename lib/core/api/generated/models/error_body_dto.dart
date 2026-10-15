// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'error_code.dart';

part 'error_body_dto.freezed.dart';
part 'error_body_dto.g.dart';

@Freezed()
abstract class ErrorBodyDto with _$ErrorBodyDto {
  const factory ErrorBodyDto({
    required ErrorCode code,

    /// Human-readable, English, for logs. Never branch on it.
    required String message,

    /// Echoed from X-Request-Id, or generated.
    required String requestId,
    required DateTime timestamp,

    /// Field issues for VALIDATION_FAILED, or string parameters for other codes.
    dynamic details,
  }) = _ErrorBodyDto;

  factory ErrorBodyDto.fromJson(Map<String, Object?> json) =>
      _$ErrorBodyDtoFromJson(json);
}
