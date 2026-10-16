import 'dart:io';

import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/home/data/hands_free_repository_impl.dart';
import 'package:alesle_ai/features/home/data/home_data_providers.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockListenHostApi extends Mock implements ListenHostApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockListenHostApi api;
  late List<ListenEventsApi?> registered;
  late HandsFreeRepositoryImpl repository;

  setUp(() {
    api = _MockListenHostApi();
    registered = <ListenEventsApi?>[];
    repository = HandsFreeRepositoryImpl(api: api, register: registered.add);
  });

  test('registers for events, and lets go on dispose', () async {
    expect(registered.single, same(repository));
    await repository.dispose();
    expect(registered.last, isNull);
  });

  test('start, stop, mute and status go to the service', () async {
    when(
      api.startListening,
    ).thenAnswer((_) async => ListenStateMessage(active: true, muted: false));
    when(api.listenState)
        .thenAnswer((_) async => ListenStateMessage(active: true, muted: true));
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
    repository.onListenState(ListenStateMessage(active: true, muted: true));
    repository.onUtterance('${dir.path}/b.wav');
    await Future<void>.delayed(Duration.zero);
    expect(states, <ListenStatus>[
      const ListenStatus(active: true, muted: true),
    ]);
    expect(paths, <String>['${dir.path}/b.wav']);
  });

  test('the provider builds the real repository', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(handsFreeRepositoryProvider),
      isA<HandsFreeRepositoryImpl>(),
    );
  });
}
