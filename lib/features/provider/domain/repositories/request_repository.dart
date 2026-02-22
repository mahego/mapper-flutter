
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/express_request.dart';

class RequestRepository {
  final ApiClient _apiClient;

  RequestRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get incoming requests (new requests available to accept)
  Future<List<dynamic>> getIncomingRequests() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.incomingRequests);
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

  /// Get express requests (open requests or active assignment)
  Future<List<ExpressRequest>> getExpressRequests() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.expressRequestsOpen);
      final data = response.data;
      
      List<dynamic> items = [];
      if (data is Map && data.containsKey('data')) {
        items = data['data'] ?? [];
      } else if (data is List) {
        items = data;
      }
      
      return items.map((item) => ExpressRequest.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Accept a request
  Future<Map<String, dynamic>> acceptRequest(String requestId, {String? estimatedArrival}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.requestAccept(requestId),
        data: estimatedArrival != null ? {'estimated_arrival': estimatedArrival} : {},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get my requests (as provider)
  Future<List<dynamic>> getMyRequests({String role = 'provider', String status = 'active'}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.requests,
        queryParameters: {
          'role': role,
          'status': status,
        },
      );
      final data = response.data;
       if (data is Map && data.containsKey('data')) {
        return data['data'] ?? [];
      }
      if (data is Map && data.containsKey('items')) {
        return data['items'] ?? []; 
      }
      if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get request detail
  Future<Map<String, dynamic>> getRequestDetail(String requestId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.requestDetail(requestId));
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Update provider location
  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _apiClient.put(
        ApiEndpoints.providerLocation,
        data: {'latitude': lat, 'longitude': lng},
      );
    } catch (e) {
      // Silently fail for tracking updates to avoid spamming errors
      print('Failed to update location: $e');
    }
  }
}
