// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'memory_kind.dart';

part 'memory_item_dto.freezed.dart';
part 'memory_item_dto.g.dart';

@Freezed()
abstract class MemoryItemDto with _$MemoryItemDto {
  const factory MemoryItemDto({
    required String id,
    required MemoryKind kind,
    required String content,
    required DateTime updatedAt,
  }) = _MemoryItemDto;

  factory MemoryItemDto.fromJson(Map<String, Object?> json) =>
      _$MemoryItemDtoFromJson(json);
}
