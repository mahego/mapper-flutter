import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class StoreRepository {
  final ApiClient _apiClient;

  StoreRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<dynamic>> getStores(double lat, double lng) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.stores,
        queryParameters: {
          'clientLat': lat,
          'clientLng': lng,
        },
      );
      
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return data['data'] ?? [];
      }
      if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> getStoreById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.stores}/$id');
      final data = response.data;
      return (data is Map && data.containsKey('data')) ? data['data'] : data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getProducts(String storeId, {String? category}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.storeProductsList(storeId),
        queryParameters: category != null ? {'category': category} : null,
      );
       final data = response.data;
       // Assuming standard response structure { data: [...] } or just [...]
      if (data is Map && data.containsKey('data')) {
        return data['data'] ?? [];
      }
      if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
