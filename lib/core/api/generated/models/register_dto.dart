// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_dto.freezed.dart';
part 'register_dto.g.dart';

@Freezed()
abstract class RegisterDto with _$RegisterDto {
  const factory RegisterDto({
    required String email,
    required String password,

    /// Shown in the device list.
    String? deviceName,

    /// App language (BCP-47) for emails.
    String? locale,
    String? displayName,
  }) = _RegisterDto;

  factory RegisterDto.fromJson(Map<String, Object?> json) =>
      _$RegisterDtoFromJson(json);
}
