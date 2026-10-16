// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'task_status.dart';

part 'history_item_dto.freezed.dart';
part 'history_item_dto.g.dart';

@Freezed()
abstract class HistoryItemDto with _$HistoryItemDto {
  const factory HistoryItemDto({
    required String id,
    required String? title,
    required TaskStatus status,

    /// What the user said.
    required String? command,

    /// What the agent answered.
    required String? reply,
    required DateTime createdAt,
  }) = _HistoryItemDto;

  factory HistoryItemDto.fromJson(Map<String, Object?> json) =>
      _$HistoryItemDtoFromJson(json);
}
