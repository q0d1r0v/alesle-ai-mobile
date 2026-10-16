/// A published APK from the release manifest (SOW 02 §3).
final class Release {
  const Release({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    required this.sha256,
    required this.certSha256,
    required this.sizeBytes,
    required this.minSupportedVersionCode,
    required this.notes,
  });

  final int versionCode;
  final String versionName;
  final Uri apkUrl;

  /// Lowercase hex SHA-256 of the APK file.
  final String sha256;

  /// Lowercase hex SHA-256 of the signing certificate.
  final String certSha256;
  final int sizeBytes;
  final int minSupportedVersionCode;

  /// Release notes by language code (en, uz, ru).
  final Map<String, String> notes;

  /// The notes in [language], else English, else none.
  String notesIn(String language) => notes[language] ?? notes['en'] ?? '';
}

enum UpdateNeed {
  /// This build is the newest (or nothing is published).
  none,

  /// A newer version exists; this one still works.
  optional,

  /// This build is below the minimum supported version (EC-15).
  required,
}

UpdateNeed updateNeed(int installedVersionCode, Release? latest) {
  if (latest == null || latest.versionCode <= installedVersionCode) {
    return UpdateNeed.none;
  }
  return installedVersionCode < latest.minSupportedVersionCode
      ? UpdateNeed.required
      : UpdateNeed.optional;
}

/// The manifest is read when the app opens and then at most daily.
bool updateCheckDue(DateTime? lastCheck, DateTime now) =>
    lastCheck == null || now.difference(lastCheck) >= const Duration(days: 1);

enum InstallResult {
  /// The system's install confirmation is showing.
  started,

  /// "Install unknown apps" is off; its settings page was opened.
  permissionNeeded,

  /// The download does not match the manifest's SHA-256 (AC-APP-6).
  corrupted,

  /// Not Alesle, not newer, or another signer (AC-APP-6).
  rejected,

  failed,
}

/// Throws a `Failure` from core/errors, except where noted.
abstract interface class UpdateRepository {
  /// The newest release; null before the first one.
  Future<Release?> latest();

  /// Downloads the APK into the app's cache and returns its path.
  /// [progress] gets 0–1.
  Future<String> download(Release release, {void Function(double)? progress});

  /// Checks the file against the manifest, then installs it. Never throws.
  Future<InstallResult> install(Release release, String path);
}
