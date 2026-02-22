import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/store_profile.dart';
import '../entities/store_metrics.dart';

class StoreRepository {
  final ApiClient _apiClient;

  StoreRepository(this._apiClient);

  Future<StoreProfile> getMyStore() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myStore);
      return StoreProfile.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener perfil de tienda: $e');
    }
  }

  Future<StoreMetrics> getMetrics() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.storeMetrics);
      return StoreMetrics.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener métricas: $e');
    }
  }

  Future<void> updateStore(Map<String, dynamic> data) async {
    try {
      await _apiClient.put(ApiEndpoints.myStore, data: data);
    } catch (e) {
      throw Exception('Error al actualizar tienda: $e');
    }
  }
}
