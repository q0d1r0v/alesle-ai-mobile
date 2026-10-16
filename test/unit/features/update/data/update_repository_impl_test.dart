import 'dart:io';

import 'package:alesle_ai/core/api/generated/clients/releases_api.dart';
import 'package:alesle_ai/core/api/generated/models/release_dto.dart';
import 'package:alesle_ai/core/api/generated/models/release_notes_dto.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/update/data/update_repository_impl.dart';
import 'package:alesle_ai/features/update/domain/update.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReleasesApi extends Mock implements ReleasesApi {}

class _MockDio extends Mock implements Dio {}

class _MockInstaller extends Mock implements UpdateHostApi {}

final List<int> _apk = <int>[1, 2, 3, 4];

Release _release({String? hash}) => Release(
  versionCode: 5,
  versionName: '0.5.0',
  apkUrl: Uri.parse('https://cdn.alesle.ai/alesle-0.5.0.apk'),
  sha256: hash ?? sha256.convert(_apk).toString(),
  certSha256: 'c' * 64,
  sizeBytes: _apk.length,
  minSupportedVersionCode: 3,
  notes: const <String, String>{'en': 'e'},
);

DioException _status(int code) => DioException(
  requestOptions: RequestOptions(path: '/v1/app/releases/latest'),
  response: Response<Object?>(
    requestOptions: RequestOptions(path: '/v1/app/releases/latest'),
    statusCode: code,
  ),
  type: DioExceptionType.badResponse,
);

void main() {
  late _MockReleasesApi releases;
  late _MockDio dio;
  late _MockInstaller installer;
  late Directory directory;
  late UpdateRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(Uri()));

  setUp(() async {
    releases = _MockReleasesApi();
    dio = _MockDio();
    installer = _MockInstaller();
    directory = await Directory.systemTemp.createTemp('alesle-update');
    repository = UpdateRepositoryImpl(
      releases: releases,
      dio: dio,
      installer: installer,
      directory: () async => directory,
    );
  });

  tearDown(() => directory.delete(recursive: true));

  test('maps the manifest', () async {
    when(releases.releasesLatest).thenAnswer(
      (_) async => ReleaseDto(
        versionCode: 5,
        versionName: '0.5.0',
        apkUrl: 'https://cdn.alesle.ai/a.apk',
        sha256: 'a' * 64,
        certSha256: 'b' * 64,
        sizeBytes: 42,
        minSupportedVersionCode: 3,
        notes: const ReleaseNotesDto(en: 'e', uz: 'u', ru: 'r'),
        publishedAt: DateTime.utc(2026, 10, 16),
      ),
    );
    final Release release = (await repository.latest())!;
    expect(release.versionCode, 5);
    expect(release.apkUrl.host, 'cdn.alesle.ai');
    expect(release.minSupportedVersionCode, 3);
    expect(release.notesIn('ru'), 'r');
  });

  test('a manifest with a non-HTTPS link is ignored', () async {
    when(releases.releasesLatest).thenAnswer(
      (_) async => ReleaseDto(
        versionCode: 5,
        versionName: '0.5.0',
        apkUrl: 'http://cdn.alesle.ai/a.apk',
        sha256: 'a' * 64,
        certSha256: 'b' * 64,
        sizeBytes: 42,
        minSupportedVersionCode: 3,
        notes: const ReleaseNotesDto(en: 'e', uz: 'u', ru: 'r'),
        publishedAt: DateTime.utc(2026, 10, 16),
      ),
    );
    expect(await repository.latest(), isNull);
    final Release plain = Release(
      versionCode: 5,
      versionName: '0.5.0',
      apkUrl: Uri.parse('http://cdn.alesle.ai/a.apk'),
      sha256: 'a' * 64,
      certSha256: 'b' * 64,
      sizeBytes: 1,
      minSupportedVersionCode: 1,
      notes: const <String, String>{},
    );
    await expectLater(
      repository.download(plain),
      throwsA(isA<UnexpectedFailure>()),
    );
  });

  test('nothing published is null; other errors are failures', () async {
    when(releases.releasesLatest).thenThrow(_status(404));
    expect(await repository.latest(), isNull);
    when(releases.releasesLatest).thenThrow(_status(500));
    await expectLater(repository.latest(), throwsA(isA<ServerFailure>()));
  });

  test('downloads into the cache with progress', () async {
    when(
      () => dio.downloadUri(
        any(),
        any<dynamic>(),
        options: any(named: 'options'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
      ),
    ).thenAnswer((Invocation call) async {
      final String path = call.positionalArguments[1] as String;
      await File(path).writeAsBytes(_apk);
      final ProgressCallback progress =
          call.namedArguments[#onReceiveProgress] as ProgressCallback;
      progress(2, -1);
      progress(4, 4);
      return Response<Object?>(requestOptions: RequestOptions());
    });
    final File stale = File('${directory.path}/alesle-4.apk')
      ..writeAsBytesSync(<int>[9]);
    final List<double> seen = <double>[];
    final String path = await repository.download(
      _release(),
      progress: seen.add,
    );
    expect(path, '${directory.path}/alesle-5.apk');
    expect(seen, <double>[0.5, 1]);
    // Earlier downloads do not pile up in the cache.
    expect(stale.existsSync(), isFalse);
  });

  test('a failed download is a failure', () async {
    when(
      () => dio.downloadUri(
        any(),
        any<dynamic>(),
        options: any(named: 'options'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(
      repository.download(_release()),
      throwsA(isA<NetworkFailure>()),
    );
  });

  Future<String> written() async {
    final File file = File('${directory.path}/alesle-5.apk');
    await file.writeAsBytes(_apk);
    return file.path;
  }

  test(
    'installs a file that matches the manifest, as the installer says',
    () async {
      final Map<InstallOutcome, InstallResult> cases =
          <InstallOutcome, InstallResult>{
            InstallOutcome.started: InstallResult.started,
            InstallOutcome.permissionNeeded: InstallResult.permissionNeeded,
            InstallOutcome.rejected: InstallResult.rejected,
            InstallOutcome.failed: InstallResult.failed,
          };
      for (final MapEntry<InstallOutcome, InstallResult> entry
          in cases.entries) {
        final String path = await written();
        when(() => installer.install(path, 'c' * 64))
            .thenAnswer((_) async => entry.key);
        expect(await repository.install(_release(), path), entry.value);
      }
    },
  );

  test('a file that does not match is deleted, never installed', () async {
    final String path = await written();
    expect(
      await repository.install(_release(hash: 'f' * 64), path),
      InstallResult.corrupted,
    );
    expect(File(path).existsSync(), isFalse);
    verifyNever(() => installer.install(any(), any()));
  });

  test('a missing file or a broken installer is a failure', () async {
    expect(
      await repository.install(_release(), '${directory.path}/none.apk'),
      InstallResult.failed,
    );
    final String path = await written();
    when(() => installer.install(path, any())).thenThrow(StateError('gone'));
    expect(await repository.install(_release(), path), InstallResult.failed);
  });
}
