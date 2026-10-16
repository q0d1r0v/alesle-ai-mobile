// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user_dto.dart';

part 'token_pair_dto.freezed.dart';
part 'token_pair_dto.g.dart';

@Freezed()
abstract class TokenPairDto with _$TokenPairDto {
  const factory TokenPairDto({
    /// Bearer token for the API and the agent socket.
    required String accessToken,

    /// Seconds until accessToken expires.
    required num expiresIn,

    /// Single use: each refresh returns a new one.
    required String refreshToken,
    required AuthUserDto user,
  }) = _TokenPairDto;

  factory TokenPairDto.fromJson(Map<String, Object?> json) =>
      _$TokenPairDtoFromJson(json);
}
