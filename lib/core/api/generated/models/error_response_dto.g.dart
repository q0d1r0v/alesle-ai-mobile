// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ErrorResponseDto _$ErrorResponseDtoFromJson(Map<String, dynamic> json) =>
    _ErrorResponseDto(
      error: ErrorBodyDto.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ErrorResponseDtoToJson(_ErrorResponseDto instance) =>
    <String, dynamic>{'error': instance.error.toJson()};
