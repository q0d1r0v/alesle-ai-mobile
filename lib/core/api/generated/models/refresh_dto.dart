// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_dto.freezed.dart';
part 'refresh_dto.g.dart';

@Freezed()
abstract class RefreshDto with _$RefreshDto {
  const factory RefreshDto({required String refreshToken}) = _RefreshDto;

  factory RefreshDto.fromJson(Map<String, Object?> json) =>
      _$RefreshDtoFromJson(json);
}
