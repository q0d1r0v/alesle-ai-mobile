import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../../core/api/generated/clients/voice_api.dart';
import '../../../core/api/generated/models/transcript_dto.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/home_repositories.dart';

final class VoiceRepositoryImpl implements VoiceRepository {
  VoiceRepositoryImpl({
    required this._dio,
    VoiceApi? api,
    DeviceHostApi? device,
    Directory? scratch,
  }) : _api = api ?? VoiceApi(_dio),
       _device = device ?? DeviceHostApi(),
       _scratch = scratch ?? Directory.systemTemp;

  final Dio _dio;
  final VoiceApi _api;
  final DeviceHostApi _device;
  final Directory _scratch;
  File? _lastReply;

  @override
  Future<bool> ensureMicrophone() => _platform(() async {
    final PermissionState state = await _device.permissionState(
      PermissionKind.microphone,
    );
    switch (state) {
      case PermissionState.granted:
        return true;
      case PermissionState.permanentlyDenied:
        await _device.openAppDetails();
        return false;
      case PermissionState.denied:
        return await _device.requestPermission(PermissionKind.microphone) ==
            PermissionState.granted;
    }
  });

  @override
  Future<void> startListening() => _platform(_device.startRecording);

  @override
  Future<void> cancelListening() => _platform(_device.cancelRecording);

  @override
  Future<Transcript?> finishListening({String? language}) async {
    final String? path = await _platform(_device.stopRecording);
    if (path == null) return null;
    final File audio = File(path);
    try {
      final TranscriptDto dto = await _api.voiceTranscribe(
        audio: audio,
        language: language,
      );
      return Transcript(
        text: dto.text,
        language: dto.language.json ?? 'other',
        confidence: dto.confidence.toDouble(),
      );
    } on Object catch (error) {
      throw mapToFailure(error);
    } finally {
      // The recording leaves the phone only for this request (A8).
      if (audio.existsSync()) audio.deleteSync();
    }
  }

  @override
  Future<void> speak(String text) async {
    final Uint8List wav;
    try {
      // The generated client reads binary bodies as text; ask Dio for bytes.
      final Response<List<int>> response = await _dio.post<List<int>>(
        '/v1/voice/speak',
        data: <String, String>{'text': text},
        options: Options(responseType: ResponseType.bytes),
      );
      wav = Uint8List.fromList(response.data ?? <int>[]);
    } on Object catch (error) {
      throw mapToFailure(error);
    }
    final File previous = _lastReply ?? File('');
    if (previous.path.isNotEmpty && previous.existsSync()) {
      previous.deleteSync();
    }
    final File reply = File(
      '${_scratch.path}/alesle-reply-${DateTime.now().microsecondsSinceEpoch}.wav',
    )..writeAsBytesSync(wav, flush: true);
    _lastReply = reply;
    await _platform(() => _device.playAudio(reply.path));
  }

  Future<T> _platform<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (error) {
      throw UnexpectedFailure(error);
    }
  }
}
