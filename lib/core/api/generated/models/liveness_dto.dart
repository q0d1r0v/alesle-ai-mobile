// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'liveness_dto_status.dart';

part 'liveness_dto.freezed.dart';
part 'liveness_dto.g.dart';

@Freezed()
abstract class LivenessDto with _$LivenessDto {
  const factory LivenessDto({
    required LivenessDtoStatus status,

    /// Short git SHA of the running build, or "unknown".
    required String commit,

    /// Process uptime in whole seconds.
    required num uptimeSeconds,
  }) = _LivenessDto;

  factory LivenessDto.fromJson(Map<String, Object?> json) =>
      _$LivenessDtoFromJson(json);
}
