// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'readiness_dto_status.dart';

part 'readiness_dto.freezed.dart';
part 'readiness_dto.g.dart';

@Freezed()
abstract class ReadinessDto with _$ReadinessDto {
  const factory ReadinessDto({
    required ReadinessDtoStatus status,
    required Map<String, String> dependencies,
  }) = _ReadinessDto;

  factory ReadinessDto.fromJson(Map<String, Object?> json) =>
      _$ReadinessDtoFromJson(json);
}
