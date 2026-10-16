import 'package:alesle_ai/core/config/app_build.dart';
import 'package:alesle_ai/core/platform/app_build_reader.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUpdateHostApi extends Mock implements UpdateHostApi {}

void main() {
  test('reads the version and certificate from Android', () async {
    final _MockUpdateHostApi api = _MockUpdateHostApi();
    when(api.appVersion).thenAnswer(
      (_) async => AppVersionMessage(
        versionCode: 3,
        versionName: '0.3.0',
        certSha256: 'ab',
      ),
    );
    final AppBuild build = await readAppBuild(api);
    expect(build.versionCode, 3);
    expect(build.versionName, '0.3.0');
    expect(build.certSha256, 'ab');
  });

  test('is unknown when Android cannot say', () async {
    final _MockUpdateHostApi api = _MockUpdateHostApi();
    when(api.appVersion).thenThrow(PlatformException(code: 'channel-error'));
    expect((await readAppBuild(api)).known, isFalse);
  });
}
