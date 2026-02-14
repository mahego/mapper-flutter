import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class RequestRepository {
  final ApiClient _apiClient;

  RequestRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

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

  Future<Map<String, dynamic>> acceptRequest(String requestId, {String? estimatedArrival}) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.requests}/$requestId/accept',
        data: estimatedArrival != null ? {'estimated_arrival': estimatedArrival} : {},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

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

  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _apiClient.put(
        ApiEndpoints.providerLocation,
        data: {'latitude': lat, 'longitude': lng},
      );
    } catch (e) {
      // Silently fail for tracking updates to avoid spamming errors?
      // Or maybe log it.
      print('Failed to update location: $e');
    }
  }
}
