import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/tracking_info.dart';

class TrackingRepository {
  final ApiClient _apiClient;

  TrackingRepository(this._apiClient);

  /// Get tracking information for a specific request
  Future<TrackingInfo> getTracking(String requestId) async {
    final response = await _apiClient.get(ApiEndpoints.trackRequest(requestId));
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    return TrackingInfo.fromJson(data);
  }

  /// Get all active requests with tracking (clients get their own requests automatically)
  Future<List<TrackingInfo>> getActiveTrackings() async {
    // Get requests that are in_progress or assigned
    final response = await _apiClient.get(
      '${ApiEndpoints.clientRequests}?status=in_progress,assigned',
    );
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    if (data is List) {
      // For each active request, we'd need to fetch tracking
      // For now, return empty list as we'd need individual tracking calls
      return [];
    }
    return [];
  }
}
