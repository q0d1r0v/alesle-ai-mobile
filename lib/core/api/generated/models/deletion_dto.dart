// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'deletion_dto.freezed.dart';
part 'deletion_dto.g.dart';

@Freezed()
abstract class DeletionDto with _$DeletionDto {
  const factory DeletionDto({required DateTime deletionScheduledAt}) =
      _DeletionDto;

  factory DeletionDto.fromJson(Map<String, Object?> json) =>
      _$DeletionDtoFromJson(json);
}
