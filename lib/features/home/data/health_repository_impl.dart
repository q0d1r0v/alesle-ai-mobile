import '../../../core/api/generated/clients/health_api.dart';
import '../../../core/api/generated/models/readiness_dto.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../domain/home_repositories.dart';
import '../domain/server_health.dart';

final class HealthRepositoryImpl implements HealthRepository {
  const HealthRepositoryImpl(this._api);

  final HealthApi _api;

  @override
  Future<ServerHealth> readiness() async {
    try {
      final ReadinessDto dto = await _api.healthReady();
      return ServerHealth(
        dependencies: Map<String, String>.of(dto.dependencies),
      );
    } on Object catch (error) {
      throw mapToFailure(error);
    }
  }
}
