// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_dto.freezed.dart';
part 'session_dto.g.dart';

@Freezed()
abstract class SessionDto with _$SessionDto {
  const factory SessionDto({
    required String id,
    required String? deviceName,
    required DateTime createdAt,
    required DateTime lastUsedAt,

    /// The device this request came from.
    required bool current,
  }) = _SessionDto;

  factory SessionDto.fromJson(Map<String, Object?> json) =>
      _$SessionDtoFromJson(json);
}
