// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TranscriptDto _$TranscriptDtoFromJson(Map<String, dynamic> json) =>
    _TranscriptDto(
      text: json['text'] as String,
      language: SpeechLanguage.fromJson(json['language'] as String),
      confidence: json['confidence'] as num,
    );

Map<String, dynamic> _$TranscriptDtoToJson(_TranscriptDto instance) =>
    <String, dynamic>{
      'text': instance.text,
      'language': instance.language.toJson(),
      'confidence': instance.confidence,
    };
