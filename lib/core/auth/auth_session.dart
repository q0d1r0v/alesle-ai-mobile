import 'dart:convert';

/// The signed-in user's tokens. Kept in the Android Keystore-backed secure
/// storage only (SOW 06 §2), never in logs.
final class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
    required this.email,
  });

  final String accessToken;

  /// Single use: every refresh returns the next one.
  final String refreshToken;
  final DateTime expiresAt;
  final String userId;
  final String email;

  bool validFor(Duration margin, DateTime now) =>
      expiresAt.isAfter(now.add(margin));

  String encode() => jsonEncode(<String, Object>{
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'userId': userId,
    'email': email,
  });

  /// Null for anything that is not a session we wrote (old format, damage).
  static AuthSession? decode(String? raw) {
    if (raw == null) return null;
    try {
      final Object? json = jsonDecode(raw);
      if (json is! Map<String, Object?>) return null;
      final Object? access = json['accessToken'];
      final Object? refresh = json['refreshToken'];
      final Object? expires = json['expiresAt'];
      final Object? userId = json['userId'];
      final Object? email = json['email'];
      if (access is! String ||
          refresh is! String ||
          expires is! String ||
          userId is! String ||
          email is! String) {
        return null;
      }
      return AuthSession(
        accessToken: access,
        refreshToken: refresh,
        expiresAt: DateTime.parse(expires),
        userId: userId,
        email: email,
      );
    } on FormatException {
      return null;
    }
  }

  @override
  String toString() => 'AuthSession(userId: $userId)';
}
