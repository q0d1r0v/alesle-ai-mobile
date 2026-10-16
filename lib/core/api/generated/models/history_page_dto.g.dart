// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryPageDto _$HistoryPageDtoFromJson(Map<String, dynamic> json) =>
    _HistoryPageDto(
      items: (json['items'] as List<dynamic>)
          .map((e) => HistoryItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: json['next'] == null
          ? null
          : DateTime.parse(json['next'] as String),
    );

Map<String, dynamic> _$HistoryPageDtoToJson(_HistoryPageDto instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'next': instance.next?.toIso8601String(),
    };
