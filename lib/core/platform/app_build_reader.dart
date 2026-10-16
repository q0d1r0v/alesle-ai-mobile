import '../config/app_build.dart';
import 'generated/agent_api.g.dart';

/// This build's version and certificate; unknown if Android cannot say.
Future<AppBuild> readAppBuild([UpdateHostApi? api]) async {
  try {
    final AppVersionMessage version = await (api ?? UpdateHostApi())
        .appVersion();
    return AppBuild(
      versionCode: version.versionCode,
      versionName: version.versionName,
      certSha256: version.certSha256,
    );
  } on Object {
    return AppBuild.unknown;
  }
}
