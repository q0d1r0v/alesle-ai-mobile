/// Result of the backend readiness check, as the home screen shows it.
final class ServerHealth {
  const ServerHealth({required this.dependencies});

  /// Dependency name -> `up` / `down`, as reported by the server.
  final Map<String, String> dependencies;

  /// Ready only when every dependency is up and there is at least one.
  bool get isReady =>
      dependencies.isNotEmpty &&
      dependencies.values.every((String status) => status == 'up');
}
