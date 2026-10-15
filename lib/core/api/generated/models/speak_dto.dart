// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'speak_dto.freezed.dart';
part 'speak_dto.g.dart';

@Freezed()
abstract class SpeakDto with _$SpeakDto {
  const factory SpeakDto({
    /// The reply to read aloud.
    required String text,
  }) = _SpeakDto;

  factory SpeakDto.fromJson(Map<String, Object?> json) =>
      _$SpeakDtoFromJson(json);
}
