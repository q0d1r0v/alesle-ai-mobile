// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user_dto.freezed.dart';
part 'auth_user_dto.g.dart';

@Freezed()
abstract class AuthUserDto with _$AuthUserDto {
  const factory AuthUserDto({required String id, required String email}) =
      _AuthUserDto;

  factory AuthUserDto.fromJson(Map<String, Object?> json) =>
      _$AuthUserDtoFromJson(json);
}
