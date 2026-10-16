import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../../core/errors/failure.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/home_repositories.dart';

/// Hands-free listening through the Kotlin microphone service. Also the one
/// receiver of its events: Pigeon allows a single handler per channel.
final class HandsFreeRepositoryImpl
    implements HandsFreeRepository, ListenEventsApi {
  HandsFreeRepositoryImpl({
    ListenHostApi? api,
    void Function(ListenEventsApi?)? register,
  }) : _api = api ?? ListenHostApi(),
       _register = register ?? ListenEventsApi.setUp {
    _register(this);
  }

  final ListenHostApi _api;
  final void Function(ListenEventsApi?) _register;
  final StreamController<ListenStatus> _status =
      StreamController<ListenStatus>.broadcast();
  final StreamController<String> _utterances =
      StreamController<String>.broadcast();

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
