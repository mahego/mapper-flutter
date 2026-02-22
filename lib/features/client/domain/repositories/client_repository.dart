import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/client_stats.dart';
import '../entities/service_request.dart';

class ClientRepository {
  final ApiClient _apiClient;

  ClientRepository(this._apiClient);

  /// Calculate client statistics from requests
  /// Since there's no backend endpoint for client stats, we calculate them from requests
  Future<ClientStats> getStats() async {
    final response = await _apiClient.get(ApiEndpoints.clientRequests);
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    
    if (data is! List) {
      return const ClientStats(
        totalRequests: 0,
        activeRequests: 0,
        completedRequests: 0,
        totalSpent: 0,
        pendingRequests: 0,
      );
    }

    final requests = data.map((item) => ServiceRequest.fromJson(item)).toList();
    
    final totalRequests = requests.length;
    final activeRequests = requests.where((r) => 
      r.status.toLowerCase() == 'in_progress' || 
      r.status.toLowerCase() == 'assigned'
    ).length;
    final completedRequests = requests.where((r) => 
      r.status.toLowerCase() == 'completed'
    ).length;
    final pendingRequests = requests.where((r) => 
      r.status.toLowerCase() == 'pending' ||
      r.status.toLowerCase() == 'negotiating'
    ).length;
    final totalSpent = requests
      .where((r) => r.status.toLowerCase() == 'completed')
      .fold(0.0, (sum, r) => sum + (r.finalCost ?? 0));

    return ClientStats(
      totalRequests: totalRequests,
      activeRequests: activeRequests,
      completedRequests: completedRequests,
      totalSpent: totalSpent,
      pendingRequests: pendingRequests,
    );
  }
}
