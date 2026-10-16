import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../../core/api/generated/clients/releases_api.dart';
import '../../../core/api/generated/models/release_dto.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/update.dart';

final class UpdateRepositoryImpl implements UpdateRepository {
  UpdateRepositoryImpl({
    required this._releases,
    required this._dio,
    required this._installer,
    required this._directory,
  });

  final ReleasesApi _releases;

  /// Downloads from the CDN (absolute URLs).
  final Dio _dio;
  final UpdateHostApi _installer;

  /// Where downloads go: the app's cache.
  final Future<Directory> Function() _directory;

  @override
  Future<Release?> latest() async {
    try {
      final ReleaseDto dto = await _releases.releasesLatest();
      return Release(
        versionCode: dto.versionCode.toInt(),
        versionName: dto.versionName,
        apkUrl: Uri.parse(dto.apkUrl),
        sha256: dto.sha256,
        certSha256: dto.certSha256,
        sizeBytes: dto.sizeBytes.toInt(),
        minSupportedVersionCode: dto.minSupportedVersionCode.toInt(),
        notes: <String, String>{
          'en': dto.notes.en,
          'uz': dto.notes.uz,
          'ru': dto.notes.ru,
        },
      );
    } on Object catch (error) {
      final Failure failure = mapToFailure(error);
      if (failure case ServerFailure(statusCode: 404)) return null;
      throw failure;
    }
  }

  @override
  Future<String> download(
    Release release, {
    void Function(double)? progress,
  }) async {
    final Directory directory = await _directory();
    final String path = '${directory.path}/alesle-${release.versionCode}.apk';
    try {
      await _dio.downloadUri(
        release.apkUrl,
        path,
        options: Options(receiveTimeout: const Duration(minutes: 5)),
        onReceiveProgress: (int received, int total) {
          final int size = total > 0 ? total : release.sizeBytes;
          if (size > 0) progress?.call((received / size).clamp(0, 1));
        },
      );
      return path;
    } on Object catch (error) {
      throw mapToFailure(error);
    }
  }

  @override
  Future<InstallResult> install(Release release, String path) async {
    try {
      final File file = File(path);
      final Digest digest = await sha256.bind(file.openRead()).first;
      if (digest.toString() != release.sha256.toLowerCase()) {
        await file.delete();
        return InstallResult.corrupted;
      }
      final InstallOutcome outcome = await _installer.install(
        path,
        release.certSha256,
      );
      return switch (outcome) {
        InstallOutcome.started => InstallResult.started,
        InstallOutcome.permissionNeeded => InstallResult.permissionNeeded,
        InstallOutcome.rejected => InstallResult.rejected,
        InstallOutcome.failed => InstallResult.failed,
      };
    } on Object {
      return InstallResult.failed;
    }
  }
}
