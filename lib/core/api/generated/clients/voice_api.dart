// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/speak_dto.dart';
import '../models/transcript_dto.dart';

part 'voice_api.g.dart';

@RestApi()
abstract class VoiceApi {
  factory VoiceApi(Dio dio, {String? baseUrl}) = _VoiceApi;

  /// [audio] - AAC, M4A, WAV, OGG, MP3 or FLAC; up to 2 MB.
  ///
  /// [language] - App language hint (BCP-47).
  @MultiPart()
  @POST('/v1/voice/transcribe')
  Future<TranscriptDto> voiceTranscribe({
    @Part(name: 'audio') required File audio,
    @Part(name: 'language') String? language,
  });

  @POST('/v1/voice/speak')
  @DioResponseType(ResponseType.stream)
  Stream<String> voiceSpeak({@Body() required SpeakDto body});
}
