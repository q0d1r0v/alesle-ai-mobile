/// The signed-in user's account as settings shows it (SOW 06 §3).
final class Profile {
  const Profile({
    required this.email,
    required this.emailVerified,
    required this.displayName,
    required this.language,
    required this.confirmSensitiveActions,
    required this.deletionScheduledAt,
  });

  final String email;
  final bool emailVerified;
  final String? displayName;

  /// uz, ru or en.
  final String language;
  final bool confirmSensitiveActions;

  /// Set when deletion was requested: erased then, unless cancelled.
  final DateTime? deletionScheduledAt;
}

/// A signed-in device.
final class Device {
  const Device({
    required this.id,
    required this.name,
    required this.lastUsedAt,
    required this.current,
  });

  final String id;
  final String? name;
  final DateTime lastUsedAt;

  /// The phone in the user's hand.
  final bool current;
}

/// Throws a `Failure` from core/errors.
abstract interface class AccountRepository {
  Future<Profile> profile();

  /// Changes only what is given; the result is the saved profile.
  Future<Profile> update({
    String? displayName,
    String? language,
    bool? confirmSensitiveActions,
  });

  Future<void> resendVerification();

  Future<List<Device>> devices();

  Future<void> removeDevice(String id);

  /// This phone only. Signed out locally even when the server cannot be reached.
  Future<void> signOut();

  /// Every device, this one included.
  Future<void> signOutEverywhere();

  /// Returns when the account will be erased.
  Future<DateTime> requestDeletion();

  Future<Profile> cancelDeletion();
}
