/// Representa un turno de la bolsa de trabajo
class Shift {
  final String id;
  final String storeId;
  final String? storeName;
  final String? storeAddress;
  final DateTime startTime;
  final DateTime endTime;
  final double? hourlyRate;
  final String status; // 'open', 'assigned', 'in_progress', 'completed', 'cancelled'
  final String? description;
  final int? applicantsCount;
  final bool? hasApplied;
  final DateTime? createdAt;

  const Shift({
    required this.id,
    required this.storeId,
    this.storeName,
    this.storeAddress,
    required this.startTime,
    required this.endTime,
    this.hourlyRate,
    required this.status,
    this.description,
    this.applicantsCount,
    this.hasApplied,
    this.createdAt,
  });

  bool get isOpen => status == 'open';
  bool get isAssigned => status == 'assigned';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  Duration get duration => endTime.difference(startTime);
  
  double get estimatedEarnings {
    if (hourlyRate == null) return 0;
    return hourlyRate! * (duration.inMinutes / 60);
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id']?.toString() ?? '0',
      storeId: json['storeId']?.toString() ?? json['store_id']?.toString() ?? '0',
      storeName: json['storeName'] ?? json['store_name'],
      storeAddress: json['storeAddress'] ?? json['store_address'],
      startTime: DateTime.parse(json['startTime'] ?? json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? json['end_time'] ?? DateTime.now().toIso8601String()),
      hourlyRate: json['hourlyRate'] != null ? (json['hourlyRate']).toDouble() : 
                   json['hourly_rate'] != null ? (json['hourly_rate']).toDouble() : null,
      status: json['status'] ?? 'open',
      description: json['description'],
      applicantsCount: json['applicantsCount'] ?? json['applicants_count'],
      hasApplied: json['hasApplied'] ?? json['has_applied'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) :
                 json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'store_name': storeName,
      'store_address': storeAddress,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'hourly_rate': hourlyRate,
      'status': status,
      'description': description,
      'applicants_count': applicantsCount,
      'has_applied': hasApplied,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Representa una postulación a un turno
class ShiftApplication {
  final String id;
  final String shiftId;
  final String providerId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime appliedAt;
  final Shift? shift;

  const ShiftApplication({
    required this.id,
    required this.shiftId,
    required this.providerId,
    required this.status,
    required this.appliedAt,
    this.shift,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  factory ShiftApplication.fromJson(Map<String, dynamic> json) {
    return ShiftApplication(
      id: json['id']?.toString() ?? '0',
      shiftId: json['shiftId']?.toString() ?? json['shift_id']?.toString() ?? '0',
      providerId: json['providerId']?.toString() ?? json['provider_id']?.toString() ?? '0',
      status: json['status'] ?? 'pending',
      appliedAt: DateTime.parse(json['appliedAt'] ?? json['applied_at'] ?? DateTime.now().toIso8601String()),
      shift: json['shift'] != null ? Shift.fromJson(json['shift']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shift_id': shiftId,
      'provider_id': providerId,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'shift': shift?.toJson(),
    };
  }
}
