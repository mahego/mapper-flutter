import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/store_product.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<StoreProduct>> getProducts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.products);
      final List<dynamic> data = response.data;
      return data.map((json) => StoreProduct.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  Future<StoreProduct> getProductById(int id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.products}/$id');
      return StoreProduct.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener producto: $e');
    }
  }

  Future<StoreProduct> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.products, data: data);
      return StoreProduct.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.put('${ApiEndpoints.products}/$id', data: data);
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.products}/$id');
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  Future<StoreProduct?> lookupByBarcode(String barcode) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.productLookupByBarcode(barcode));
      if (response.data == null) return null;
      return StoreProduct.fromJson(response.data);
    } catch (e) {
      // Return null if not found instead of throwing
      return null;
    }
  }
}
