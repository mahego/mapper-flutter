import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/provider_stats.dart';
import '../entities/earnings.dart';
import '../entities/subscription.dart';

class ProviderRepository {
  final ApiClient _apiClient;

  ProviderRepository({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient();

  /// Get provider statistics (pending/completed requests, earnings)
  Future<ProviderStats> getStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.providerStats);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        return ProviderStats.fromJson(data['data']);
      }
      return ProviderStats.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get earnings breakdown for a period ('today', 'week', 'month')
  Future<Earnings> getEarnings({String period = 'month'}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.providerEarnings,
        queryParameters: {'period': period},
      );
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        return Earnings.fromJson(data['data']);
      }
      return Earnings.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get provider online/offline status
  Future<bool> getOnlineStatus() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.providerStatus);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final statusData = data['data'];
        return statusData['is_effectively_online'] ?? 
               statusData['is_online'] ?? 
               false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Set provider online/offline status
  Future<void> setOnlineStatus(bool isOnline) async {
    try {
      await _apiClient.post(
        ApiEndpoints.providerOnlineStatus,
        data: {'is_online': isOnline},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update provider location
  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _apiClient.put(
        ApiEndpoints.providerLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
    } catch (e) {
      // Silent fail for location updates
      print('Failed to update location: $e');
    }
  }

  /// Get my services
  Future<List<dynamic>> getMyServices() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myServices);
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

  /// Get current subscription
  Future<Subscription?> getCurrentSubscription() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.currentSubscription);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        return Subscription.fromJson(data['data']);
      }
      return Subscription.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
