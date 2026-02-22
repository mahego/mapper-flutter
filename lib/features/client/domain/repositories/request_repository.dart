import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/service_request.dart';

class RequestRepository {
  final ApiClient _apiClient;

  RequestRepository(this._apiClient);

  /// Get all requests for the current client
  Future<List<ServiceRequest>> getMyRequests() async {
    final response = await _apiClient.get(ApiEndpoints.clientRequests);
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    if (data is List) {
      return data.map((item) => ServiceRequest.fromJson(item)).toList();
    }
    return [];
  }

  /// Get a specific request by ID
  Future<ServiceRequest> getRequestById(String requestId) async {
    final response = await _apiClient.get(ApiEndpoints.requestDetail(requestId));
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    return ServiceRequest.fromJson(data);
  }

  /// Create a new service request
  Future<ServiceRequest> createRequest(Map<String, dynamic> requestData) async {
    final response = await _apiClient.post(
      ApiEndpoints.createRequest,
      data: requestData,
    );
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    return ServiceRequest.fromJson(data);
  }

  /// Update an existing request
  Future<ServiceRequest> updateRequest(String requestId, Map<String, dynamic> updates) async {
    final response = await _apiClient.put(
      ApiEndpoints.updateRequest(requestId),
      data: updates,
    );
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    return ServiceRequest.fromJson(data);
  }
}
