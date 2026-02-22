import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/store_order.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<List<StoreOrder>> getOrders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.storeOrders);
      final List<dynamic> data = response.data;
      return data.map((json) => StoreOrder.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener pedidos: $e');
    }
  }

  Future<StoreOrder> getOrderById(int id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.storeOrders}/$id');
      return StoreOrder.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener pedido: $e');
    }
  }

  Future<StoreOrder> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.storeOrders, data: data);
      return StoreOrder.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear pedido: $e');
    }
  }

  Future<void> updateOrderStatus(int id, String status) async {
    try {
      await _apiClient.put('${ApiEndpoints.storeOrders}/$id', data: {
        'status': status,
      });
    } catch (e) {
      throw Exception('Error al actualizar estado del pedido: $e');
    }
  }
}
