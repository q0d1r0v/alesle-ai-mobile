import 'dart:io';

import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/home/data/hands_free_repository_impl.dart';
import 'package:alesle_ai/features/home/data/home_data_providers.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:alesle_ai/features/home/domain/live.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';

class _MockListenHostApi extends Mock implements ListenHostApi {}

const AppConfig _config = AppConfig(
  environment: AppEnvironment.dev,
  apiBaseUrl: 'http://127.0.0.1:3000',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockListenHostApi api;
  late List<ListenEventsApi?> registered;
  late HandsFreeRepositoryImpl repository;
  late FakeTokens tokens;

  setUpAll(() {
    registerFallbackValue(
      LiveConfig(apiBaseUrl: '', accessToken: '', locale: ''),
    );
  });

  setUp(() {
    api = _MockListenHostApi();
    registered = <ListenEventsApi?>[];
    tokens = FakeTokens();
    repository = HandsFreeRepositoryImpl(
      config: _config,
      tokens: tokens,
      api: api,
      register: registered.add,
    );
  });

  test('registers for events, and lets go on dispose', () async {
    expect(registered.single, same(repository));
    await repository.dispose();
    expect(registered.last, isNull);
  });

  test('start, stop, mute and status go to the service', () async {
    when(api.startListening).thenAnswer(
      (_) async =>
          ListenStateMessage(active: true, muted: false, paused: false),
    );
    when(api.listenState).thenAnswer(
      (_) async => ListenStateMessage(active: true, muted: true, paused: false),
    );
    when(api.stopListening).thenAnswer((_) async {});
    when(() => api.setMuted(true)).thenAnswer((_) async {});
    expect(
      await repository.start(),
      const ListenStatus(active: true, muted: false),
    );
    expect(
      await repository.status(),
      const ListenStatus(active: true, muted: true),
    );
    await repository.setMuted(true);
    await repository.stop();
    verify(() => api.setMuted(true)).called(1);
    verify(api.stopListening).called(1);

    when(api.startListening).thenThrow(PlatformException(code: 'x'));
    await expectLater(repository.start(), throwsA(isA<UnexpectedFailure>()));
  });

  test('passes state and utterances on; unheard audio is deleted', () async {
    final List<ListenStatus> states = <ListenStatus>[];
    final List<String> paths = <String>[];
    final Directory dir = Directory.systemTemp.createTempSync('hf');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File nobody = File('${dir.path}/a.wav')..writeAsBytesSync(<int>[1]);
    repository.onUtterance(nobody.path);
    expect(nobody.existsSync(), isFalse);

    repository.statusChanges.listen(states.add);
    repository.utterances.listen(paths.add);
    repository.onListenState(
      ListenStateMessage(active: true, muted: true, paused: false),
    );
    repository.onListenState(
      ListenStateMessage(active: true, muted: false, paused: true),
    );
    repository.onUtterance('${dir.path}/b.wav');
    await Future<void>.delayed(Duration.zero);
    expect(states, <ListenStatus>[
      const ListenStatus(active: true, muted: true),
      const ListenStatus(active: true, muted: false, paused: true),
    ]);
    expect(paths, <String>['${dir.path}/b.wav']);
  });

  test('a live conversation gets the server and a token; signed out it is plain hands-free', () async {
    when(() => api.startLive(any())).thenAnswer(
      (_) async =>
          ListenStateMessage(active: true, muted: false, paused: false),
    );
    expect(
      await repository.startLive(locale: 'uz'),
      const ListenStatus(active: true, muted: false),
    );
    final LiveConfig config =
        verify(() => api.startLive(captureAny())).captured.single as LiveConfig;
    expect(config.apiBaseUrl, 'http://127.0.0.1:3000');
    expect(config.accessToken, 'access-token');
    expect(config.locale, 'uz');

    tokens.token = null;
    when(api.startListening).thenAnswer(
      (_) async =>
          ListenStateMessage(active: true, muted: false, paused: false),
    );
    await repository.startLive(locale: 'uz');
    verify(api.startListening).called(1);
  });

  test('a refused token is refreshed and handed over; typing and task results go through', () async {
    tokens.refreshesTo = 'fresh';
    when(() => api.updateLiveToken('fresh')).thenAnswer((_) async {});
    when(() => api.sendLiveText('Salom')).thenAnswer((_) async {});
    when(() => api.liveTaskResult('c1', 'done', 'Soat ochildi', null))
        .thenAnswer((_) async {});
    when(() => api.liveTaskResult('c2', 'failed', null, 'ai_unavailable'))
        .thenAnswer((_) async {});
    await repository.refreshLiveToken();
    expect(tokens.forced, 1);
    verify(() => api.updateLiveToken('fresh')).called(1);
    await repository.sendLiveText('Salom');
    await repository.liveTaskResult(
      'c1',
      status: 'done',
      reply: 'Soat ochildi',
    );
    verify(() => api.liveTaskResult('c1', 'done', 'Soat ochildi', null))
        .called(1);
    await repository.liveTaskResult(
      'c2',
      status: 'failed',
      reason: 'ai_unavailable',
    );
    verify(() => api.liveTaskResult('c2', 'failed', null, 'ai_unavailable'))
        .called(1);

    tokens.refreshesTo = null;
    await repository.refreshLiveToken();
    verifyNever(() => api.updateLiveToken(any()));
  });

  test('live events become updates', () async {
    final List<LiveUpdate> updates = <LiveUpdate>[];
    repository.liveUpdates.listen(updates.add);
    repository
      ..onLiveEvent(
        LiveEvent(kind: LiveEventKind.phase, phase: LivePhase.speaking),
      )
      ..onLiveEvent(LiveEvent(kind: LiveEventKind.phase))
      ..onLiveEvent(
        LiveEvent(
          kind: LiveEventKind.caption,
          role: 'user',
          text: 'Salom',
          isFinal: true,
        ),
      )
      ..onLiveEvent(
        LiveEvent(kind: LiveEventKind.caption, role: 'assistant', text: 'Hi'),
      )
      ..onLiveEvent(
        LiveEvent(
          kind: LiveEventKind.taskRun,
          callId: 'c1',
          text: 'Soatni och',
        ),
      )
      ..onLiveEvent(LiveEvent(kind: LiveEventKind.taskAmend, text: 'ham'))
      ..onLiveEvent(LiveEvent(kind: LiveEventKind.taskStop))
      ..onLiveEvent(LiveEvent(kind: LiveEventKind.end))
      ..onLiveEvent(LiveEvent(kind: LiveEventKind.level, level: 0.5))
      ..onLiveEvent(LiveEvent(kind: LiveEventKind.level, level: 3))
      ..onLiveEvent(LiveEvent(kind: LiveEventKind.level));
    await Future<void>.delayed(Duration.zero);
    expect(updates, <LiveUpdate>[
      const LiveStageChanged(LiveStage.speaking),
      const LiveCaption(fromUser: true, text: 'Salom', isFinal: true),
      const LiveCaption(fromUser: false, text: 'Hi', isFinal: false),
      const LiveTaskRun(callId: 'c1', command: 'Soatni och'),
      const LiveTaskAmend('ham'),
      const LiveTaskStop(),
      const LiveEnded(),
      const LiveLevel(0.5),
      const LiveLevel(1),
      const LiveLevel(0),
    ]);
  });

  test('the provider builds the real repository', () {
    final ProviderContainer container = ProviderContainer(
      overrides: [appConfigProvider.overrideWithValue(_config)],
    );
    addTearDown(container.dispose);
    expect(
      container.read(handsFreeRepositoryProvider),
      isA<HandsFreeRepositoryImpl>(),
    );
  });
}
