import 'dart:io';

import 'package:alesle_ai/core/api/generated/clients/voice_api.dart';
import 'package:alesle_ai/core/api/generated/models/speech_language.dart';
import 'package:alesle_ai/core/api/generated/models/transcript_dto.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/home/data/voice_repository_impl.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';

class _MockDeviceHostApi extends Mock implements DeviceHostApi {}

class _MockVoiceApi extends Mock implements VoiceApi {}

void main() {
  late _MockDeviceHostApi device;
  late _MockVoiceApi api;
  late Dio dio;
  late DioAdapter adapter;
  late Directory scratch;
  late VoiceRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(PermissionKind.microphone);
    registerFallbackValue(File(''));
  });

  setUp(() {
    device = _MockDeviceHostApi();
    api = _MockVoiceApi();
    dio = Dio(BaseOptions(baseUrl: 'http://api.test'));
    adapter = DioAdapter(dio: dio);
    scratch = Directory.systemTemp.createTempSync('voice-test');
    addTearDown(() => scratch.deleteSync(recursive: true));
    repository = VoiceRepositoryImpl(
      dio: dio,
      api: api,
      device: device,
      scratch: scratch,
    );
  });

  File recording() =>
      File('${scratch.path}/rec.aac')..writeAsBytesSync(<int>[1, 2, 3]);

  group('ensureMicrophone', () {
    test('granted: yes, without asking', () async {
      when(() => device.permissionState(PermissionKind.microphone))
          .thenAnswer((_) async => PermissionState.granted);
      expect(await repository.ensureMicrophone(), isTrue);
      verifyNever(() => device.requestPermission(any()));
    });

    test('denied: asks once and follows the answer', () async {
      when(() => device.permissionState(PermissionKind.microphone))
          .thenAnswer((_) async => PermissionState.denied);
      when(() => device.requestPermission(PermissionKind.microphone))
          .thenAnswer((_) async => PermissionState.granted);
      expect(await repository.ensureMicrophone(), isTrue);
      when(() => device.requestPermission(PermissionKind.microphone))
          .thenAnswer((_) async => PermissionState.denied);
      expect(await repository.ensureMicrophone(), isFalse);
    });

    test('"don\'t ask again": opens app info', () async {
      when(() => device.permissionState(PermissionKind.microphone))
          .thenAnswer((_) async => PermissionState.permanentlyDenied);
      when(device.openAppDetails).thenAnswer((_) async {});
      expect(await repository.ensureMicrophone(), isFalse);
      verify(device.openAppDetails).called(1);
    });

    test('a platform error is an UnexpectedFailure', () async {
      when(() => device.permissionState(any()))
          .thenThrow(PlatformException(code: 'x'));
      await expectLater(
        repository.ensureMicrophone(),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });

  test('start and cancel go to the recorder', () async {
    when(device.startRecording).thenAnswer((_) async {});
    when(device.cancelRecording).thenAnswer((_) async {});
    await repository.startListening();
    await repository.cancelListening();
    verify(device.startRecording).called(1);
    verify(device.cancelRecording).called(1);
  });

  group('finishListening', () {
    test('too short: nothing to send', () async {
      when(device.stopRecording).thenAnswer((_) async => null);
      expect(await repository.finishListening(), isNull);
      verifyNever(
        () => api.voiceTranscribe(
          audio: any(named: 'audio'),
          language: any(named: 'language'),
        ),
      );
    });

    test('transcribes, then deletes the recording', () async {
      final File audio = recording();
      when(device.stopRecording).thenAnswer((_) async => audio.path);
      when(
        () => api.voiceTranscribe(
          audio: any(named: 'audio'),
          language: 'uz',
        ),
      ).thenAnswer(
        (_) async => const TranscriptDto(
          text: 'Salom',
          language: SpeechLanguage.uz,
          confidence: 0.98,
        ),
      );

      final Transcript? transcript = await repository.finishListening(
        language: 'uz',
      );
      expect(transcript?.text, 'Salom');
      expect(transcript?.language, 'uz');
      expect(transcript?.confidence, 0.98);
      expect(audio.existsSync(), isFalse);
    });

    test('an unknown language reads as other', () async {
      final File audio = recording();
      when(device.stopRecording).thenAnswer((_) async => audio.path);
      when(() => api.voiceTranscribe(audio: any(named: 'audio'))).thenAnswer(
        (_) async => const TranscriptDto(
          text: 'x',
          language: SpeechLanguage.$unknown,
          confidence: 1,
        ),
      );
      expect((await repository.finishListening())?.language, 'other');
    });

    test(
      'a failed upload is a Failure and still deletes the recording',
      () async {
        final File audio = recording();
        when(device.stopRecording).thenAnswer((_) async => audio.path);
        when(() => api.voiceTranscribe(audio: any(named: 'audio'))).thenThrow(
          DioException.connectionError(
            requestOptions: RequestOptions(path: '/v1/voice/transcribe'),
            reason: 'offline',
          ),
        );
        await expectLater(
          repository.finishListening(),
          throwsA(isA<NetworkFailure>()),
        );
        expect(audio.existsSync(), isFalse);
      },
    );
  });

  group('speak', () {
    test('plays the reply and keeps only the latest file', () async {
      // Raw WAV bytes; the mock adapter would JSON-encode a list.
      dio.httpClientAdapter = _BytesAdapter(<int>[82, 73, 70, 70]);
      final List<String> played = <String>[];
      when(() => device.playAudio(any())).thenAnswer((Invocation call) async {
        played.add(call.positionalArguments.single as String);
      });

      await repository.speak('Tayyor');
      await repository.speak('Tayyor');

      expect(played, hasLength(2));
      expect(File(played.first).existsSync(), isFalse);
      expect(File(played.last).readAsBytesSync(), <int>[82, 73, 70, 70]);
    });

    test('a server error is a Failure', () async {
      adapter.onPost(
        '/v1/voice/speak',
        (server) => server.reply(503, <String, Object>{
          'code': 'VOICE_UNAVAILABLE',
          'message': 'x',
        }),
        data: <String, String>{'text': 'x'},
      );
      await expectLater(repository.speak('x'), throwsA(isA<Failure>()));
      verifyNever(() => device.playAudio(any()));
    });
  });

  test('defaults to the generated client and the real host API', () {
    expect(VoiceRepositoryImpl(dio: dio), isA<VoiceRepositoryImpl>());
  });
}

/// Answers every request with [bytes] as an audio body.
final class _BytesAdapter implements HttpClientAdapter {
  _BytesAdapter(this.bytes);

  final List<int> bytes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromBytes(
    bytes,
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>['audio/wav'],
    },
  );

  @override
  void close({bool force = false}) {}
}
