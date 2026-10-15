// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'error_body_dto.dart';

part 'error_response_dto.freezed.dart';
part 'error_response_dto.g.dart';

@Freezed()
abstract class ErrorResponseDto with _$ErrorResponseDto {
  const factory ErrorResponseDto({required ErrorBodyDto error}) =
      _ErrorResponseDto;

  factory ErrorResponseDto.fromJson(Map<String, Object?> json) =>
      _$ErrorResponseDtoFromJson(json);
}
