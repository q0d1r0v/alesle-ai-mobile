// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'profile_language.dart';

part 'update_profile_dto.freezed.dart';
part 'update_profile_dto.g.dart';

@Freezed()
abstract class UpdateProfileDto with _$UpdateProfileDto {
  const factory UpdateProfileDto({
    required String? displayName,
    required ProfileLanguage? language,
    required String? timeZone,
    required bool? confirmSensitiveActions,
  }) = _UpdateProfileDto;

  factory UpdateProfileDto.fromJson(Map<String, Object?> json) =>
      _$UpdateProfileDtoFromJson(json);
}
