/// Signing in (SOW 06 §1). Every method throws a `Failure` from core/errors;
/// a successful one leaves the app signed in.
abstract interface class AuthRepository {
  /// "Continue with Google" is offered only when the build is set up for it.
  bool get googleAvailable;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// False when the user closed Google's account picker.
  Future<bool> signInWithGoogle();

  /// Emails a one-time sign-in link; succeeds whether or not the email has an account.
  Future<void> sendMagicLink(String email);

  /// The token from an opened sign-in link.
  Future<void> signInWithMagicLink(String token);

  /// The token from an opened confirmation link.
  Future<void> verifyEmail(String token);
}

/// A link from an email, opened in the app (App Links, EC-AU-1).
sealed class EmailLink {
  const EmailLink(this.token);

  final String token;

  /// `https://alesle.ai/auth/link?token=…` or `/auth/verify?token=…`; null otherwise.
  static EmailLink? parse(Uri uri) {
    final String? token = uri.queryParameters['token'];
    if (token == null || token.isEmpty) return null;
    if (uri.scheme != 'https' || uri.host != 'alesle.ai') return null;
    return switch (uri.path) {
      '/auth/link' => SignInLink(token),
      '/auth/verify' => VerifyLink(token),
      _ => null,
    };
  }
}

final class SignInLink extends EmailLink {
  const SignInLink(super.token);
}

final class VerifyLink extends EmailLink {
  const VerifyLink(super.token);
}
