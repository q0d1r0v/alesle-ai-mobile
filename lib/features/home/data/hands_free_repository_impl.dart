import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../../core/auth/access_token_source.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/home_repositories.dart';
import '../domain/live.dart';

/// Hands-free listening through the Kotlin microphone service. Also the one
/// receiver of its events: Pigeon allows a single handler per channel.
final class HandsFreeRepositoryImpl
    implements HandsFreeRepository, ListenEventsApi {
  HandsFreeRepositoryImpl({
    required this._config,
    required this._tokens,
    ListenHostApi? api,
    void Function(ListenEventsApi?)? register,
  }) : _api = api ?? ListenHostApi(),
       _register = register ?? ListenEventsApi.setUp {
    _register(this);
  }

  final AppConfig _config;
  final AccessTokenSource _tokens;
  final ListenHostApi _api;
  final void Function(ListenEventsApi?) _register;
  final StreamController<ListenStatus> _status =
      StreamController<ListenStatus>.broadcast();
  final StreamController<String> _utterances =
      StreamController<String>.broadcast();
  final StreamController<LiveUpdate> _live =
      StreamController<LiveUpdate>.broadcast();

  @override
  Stream<ListenStatus> get statusChanges => _status.stream;

  @override
  Stream<String> get utterances => _utterances.stream;

  @override
  Future<ListenStatus> start() async =>
      _of(await _platform(_api.startListening));

  @override
  Future<void> stop() => _platform(_api.stopListening);

  @override
  Future<void> setMuted(bool muted) => _platform(() => _api.setMuted(muted));

  @override
  Future<ListenStatus> status() async => _of(await _platform(_api.listenState));

  @override
  Stream<LiveUpdate> get liveUpdates => _live.stream;

  @override
  Future<ListenStatus> startLive({required String locale}) async {
    // The socket checks the token once, when it opens.
    final String? token = await _tokens.accessToken();
    if (token == null) return start();
    return _of(
      await _platform(
        () => _api.startLive(
          LiveConfig(
            apiBaseUrl: _config.apiBaseUrl,
            accessToken: token,
            locale: locale,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> refreshLiveToken() async {
    final String? token = await _tokens.accessToken(forceRefresh: true);
    if (token == null) return;
    await _platform(() => _api.updateLiveToken(token));
  }

  @override
  Future<void> sendLiveText(String text) =>
      _platform(() => _api.sendLiveText(text));

  @override
  Future<void> liveTaskResult(
    String callId, {
    required String status,
    String? reply,
  }) => _platform(() => _api.liveTaskResult(callId, status, reply));

  @override
  void onLiveEvent(LiveEvent event) {
    final LiveUpdate? update = switch (event.kind) {
      LiveEventKind.phase => switch (event.phase) {
        final LivePhase phase => LiveStageChanged(
          LiveStage.values.byName(phase.name),
        ),
        null => null,
      },
      LiveEventKind.caption => LiveCaption(
        fromUser: event.role == 'user',
        text: event.text ?? '',
        isFinal: event.isFinal ?? false,
      ),
      LiveEventKind.taskRun => LiveTaskRun(
        callId: event.callId ?? '',
        command: event.text ?? '',
      ),
      LiveEventKind.taskAmend => LiveTaskAmend(event.text ?? ''),
      LiveEventKind.taskStop => const LiveTaskStop(),
    };
    if (update != null) _live.add(update);
  }

  @override
  void onListenState(ListenStateMessage state) => _status.add(_of(state));

  @override
  void onUtterance(String path) {
    if (!_utterances.hasListener) {
      // Nobody to hear it: the audio is not kept.
      final File file = File(path);
      if (file.existsSync()) file.deleteSync();
      return;
    }
    _utterances.add(path);
  }

  /// Unregisters from the channel.
  Future<void> dispose() async {
    _register(null);
    await _status.close();
    await _utterances.close();
    await _live.close();
  }

  static ListenStatus _of(ListenStateMessage message) =>
      ListenStatus(active: message.active, muted: message.muted);

  Future<T> _platform<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (error) {
      throw UnexpectedFailure(error);
    }
  }
}
