import 'package:google_sign_in/google_sign_in.dart';

/// Google's account picker (Credential Manager on Android) for an ID token.
abstract interface class GoogleIdTokens {
  /// The ID token, or null when the user cancelled.
  Future<String?> idToken();
}

final class PluginGoogleIdTokens implements GoogleIdTokens {
  PluginGoogleIdTokens(this._serverClientId);

  final String _serverClientId;
  bool _initialized = false;

  @override
  Future<String?> idToken() async {
    final GoogleSignIn google = GoogleSignIn.instance;
    if (!_initialized) {
      await google.initialize(serverClientId: _serverClientId);
      _initialized = true;
    }
    try {
      final GoogleSignInAccount account = await google.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }
}
