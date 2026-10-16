/// Hands out a bearer token for the API and the agent socket.
abstract interface class AccessTokenSource {
  /// A token valid for at least [margin], refreshing when needed; null when
  /// signed out. [forceRefresh]: the server refused the current one.
  Future<String?> accessToken({
    Duration margin = const Duration(minutes: 1),
    bool forceRefresh = false,
  });
}
