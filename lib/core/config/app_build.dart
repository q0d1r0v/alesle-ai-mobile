/// This installed build, as Android reports it (SOW 02 §3).
final class AppBuild {
  const AppBuild({
    required this.versionCode,
    required this.versionName,
    required this.certSha256,
  });

  /// Before the platform answered (tests, a failed read): nothing is claimed.
  static const AppBuild unknown = AppBuild(
    versionCode: 0,
    versionName: '',
    certSha256: '',
  );

  final int versionCode;
  final String versionName;

  /// Lowercase hex SHA-256 of the signing certificate.
  final String certSha256;

  bool get known => versionCode > 0;
}
