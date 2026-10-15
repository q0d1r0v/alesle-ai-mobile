// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'speech_language.dart';

part 'transcript_dto.freezed.dart';
part 'transcript_dto.g.dart';

@Freezed()
abstract class TranscriptDto with _$TranscriptDto {
  const factory TranscriptDto({
    /// What was said, in the language and script it was said in; "" when nothing was understood.
    required String text,
    required SpeechLanguage language,
    required num confidence,
  }) = _TranscriptDto;

  factory TranscriptDto.fromJson(Map<String, Object?> json) =>
      _$TranscriptDtoFromJson(json);
}
