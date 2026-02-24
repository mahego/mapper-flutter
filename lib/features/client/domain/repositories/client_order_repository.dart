import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/client_order.dart';

class ClientOrderRepository {
  final ApiClient _apiClient;

  ClientOrderRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Creates a store order from the client side
  /// POST /api/stores/:storeId/orders
  Future<ClientOrder> createOrder({
    required String storeId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required double deliveryLat,
    required double deliveryLng,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/stores/$storeId/orders',
        data: {
          'items': items.map((item) {
            final q = item['quantity'];
            final quantity = q is int ? q : (q is num ? q.toInt() : (int.tryParse(q?.toString() ?? '') ?? 0));
            return {
              'productId': item['productId']?.toString(),
              'quantity': quantity,
            };
          }).toList(),
          'deliveryAddress': deliveryAddress,
          'deliveryLat': deliveryLat is int ? deliveryLat.toDouble() : deliveryLat,
          'deliveryLng': deliveryLng is int ? deliveryLng.toDouble() : deliveryLng,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      final data = response.data;
      final orderData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return ClientOrder.fromJson(orderData);
    } catch (e) {
      throw Exception('Error al crear pedido: $e');
    }
  }

  /// Get orders for the current client
  /// GET /api/stores/:storeId/orders
  Future<List<ClientOrder>> getOrders(String storeId) async {
    try {
      final response = await _apiClient.get('/stores/$storeId/orders');
      
      final data = response.data;
      final ordersList = (data is Map && data.containsKey('data')) ? data['data'] : data;
      
      if (ordersList is! List) {
        return [];
      }

      return ordersList.map((json) => ClientOrder.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener pedidos: $e');
    }
  }

  /// Get a specific order by ID
  /// GET /api/stores/:storeId/orders/:orderId
  Future<ClientOrder> getOrderById(String storeId, String orderId) async {
    try {
      final response = await _apiClient.get('/stores/$storeId/orders/$orderId');
      
      final data = response.data;
      final orderData = (data is Map && data.containsKey('data')) ? data['data'] : data;
      return ClientOrder.fromJson(orderData);
    } catch (e) {
      throw Exception('Error al obtener pedido: $e');
    }
  }

  /// Cancel an order
  /// PUT /api/stores/:storeId/orders/:orderId
  Future<void> cancelOrder(String storeId, String orderId) async {
    try {
      await _apiClient.put(
        '/stores/$storeId/orders/$orderId',
        data: {'status': 'cancelled'},
      );
    } catch (e) {
      throw Exception('Error al cancelar pedido: $e');
    }
  }
}
