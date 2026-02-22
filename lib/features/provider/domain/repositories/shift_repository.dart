import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/shift.dart';

class ShiftRepository {
  final ApiClient _apiClient;

  ShiftRepository({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient();

  /// Get open shifts available for application
  Future<List<Shift>> getOpenShifts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.shiftsOpen);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final shifts = data['data'] as List?;
        return shifts?.map((s) => Shift.fromJson(s)).toList() ?? [];
      }
      if (data is List) {
        return data.map((s) => Shift.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get my shift applications
  Future<List<ShiftApplication>> getMyApplications() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myApplications);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final applications = data['data'] as List?;
        return applications?.map((a) => ShiftApplication.fromJson(a)).toList() ?? [];
      }
      if (data is List) {
        return data.map((a) => ShiftApplication.fromJson(a)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get my assigned/active shifts
  Future<List<Shift>> getMyShifts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myShifts);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final shifts = data['data'] as List?;
        return shifts?.map((s) => Shift.fromJson(s)).toList() ?? [];
      }
      if (data is List) {
        return data.map((s) => Shift.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get active shift for today (assigned or in_progress)
  Future<Shift?> getActiveShiftToday() async {
    try {
      final myShifts = await getMyShifts();
      final now = DateTime.now();
      
      // Find shift that's today and is assigned or in_progress
      for (final shift in myShifts) {
        final isToday = shift.startTime.year == now.year &&
                       shift.startTime.month == now.month &&
                       shift.startTime.day == now.day;
        
        if (isToday && (shift.isAssigned || shift.isInProgress)) {
          return shift;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Apply to a shift
  Future<void> applyToShift(String shiftId) async {
    try {
      await _apiClient.post(ApiEndpoints.applyToShift(shiftId));
    } catch (e) {
      rethrow;
    }
  }

  /// Get shift details
  Future<Shift> getShiftDetail(String shiftId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.shiftDetail(shiftId));
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        return Shift.fromJson(data['data']);
      }
      return Shift.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm arrival to shift (store confirms provider arrived)
  Future<void> confirmArrival(String shiftId) async {
    try {
      await _apiClient.post(ApiEndpoints.confirmArrival(shiftId));
    } catch (e) {
      rethrow;
    }
  }
}
