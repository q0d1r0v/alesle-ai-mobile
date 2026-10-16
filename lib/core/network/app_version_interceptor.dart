import 'package:dio/dio.dart';

/// The header the server gates outdated apps by (EC-15).
const String appVersionHeader = 'X-App-Version';

/// Sends this build's versionCode with every request, and reports a
/// 426 UPGRADE_REQUIRED answer so the app can show the update screen.
class AppVersionInterceptor extends Interceptor {
  AppVersionInterceptor(this.versionCode, {this.onUpgradeRequired});

  /// 0 when unknown: then nothing is sent.
  final int versionCode;
  final void Function()? onUpgradeRequired;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (versionCode > 0) options.headers[appVersionHeader] = '$versionCode';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 426) onUpgradeRequired?.call();
    handler.next(err);
  }
}
