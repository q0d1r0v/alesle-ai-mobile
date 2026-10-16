// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_pair_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenPairDto _$TokenPairDtoFromJson(Map<String, dynamic> json) =>
    _TokenPairDto(
      accessToken: json['accessToken'] as String,
      expiresIn: json['expiresIn'] as num,
      refreshToken: json['refreshToken'] as String,
      user: AuthUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TokenPairDtoToJson(_TokenPairDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'expiresIn': instance.expiresIn,
      'refreshToken': instance.refreshToken,
      'user': instance.user.toJson(),
    };
