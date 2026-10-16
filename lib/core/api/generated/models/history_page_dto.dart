// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'history_item_dto.dart';

part 'history_page_dto.freezed.dart';
part 'history_page_dto.g.dart';

@Freezed()
abstract class HistoryPageDto with _$HistoryPageDto {
  const factory HistoryPageDto({
    required List<HistoryItemDto> items,

    /// Pass as `before` for the next page; null on the last page.
    required DateTime? next,
  }) = _HistoryPageDto;

  factory HistoryPageDto.fromJson(Map<String, Object?> json) =>
      _$HistoryPageDtoFromJson(json);
}
