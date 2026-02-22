
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class StoreManagementRepository {
  final ApiClient _apiClient;

  StoreManagementRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getMyStore() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myStore);
      final data = response.data;
      return (data is Map && data.containsKey('data')) ? data['data'] : data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createStore(Map<String, dynamic> storeData) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.stores, data: storeData);
      final data = response.data;
      return (data is Map && data.containsKey('data')) ? data['data'] : data;
    } catch (e) {
      rethrow;
    }
  }

   Future<Map<String, dynamic>> updateStore(String storeId, Map<String, dynamic> storeData) async {
    try {
      final response = await _apiClient.patch('${ApiEndpoints.stores}/$storeId', data: storeData);
      final data = response.data;
      return (data is Map && data.containsKey('data')) ? data['data'] : data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMyProducts(String storeId, {bool active = true}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.storeProductsList(storeId),
        queryParameters: {'isActive': active},
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
      rethrow;
    }
  }

  Future<void> createProduct(String storeId, Map<String, dynamic> productData) async {
    try {
      await _apiClient.post(ApiEndpoints.storeProductsList(storeId), data: productData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      await _apiClient.patch('${ApiEndpoints.storeProducts}/$productId', data: productData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getStoreOrders(String storeId, {String? status}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.storeOrders,
        queryParameters: {
          'storeId': storeId,
          if (status != null && status != 'all') 'status': status,
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
      rethrow;
    }
  }
}
