class Subscription {
  final int id;
  final String planType;
  final String status;
  final DateTime? endDate;
  final int daysRemaining;
  final bool autoRenew;
  final DateTime? startDate;
  final double price;

  const Subscription({
    required this.id,
    required this.planType,
    required this.status,
    this.endDate,
    this.daysRemaining = 0,
    this.autoRenew = false,
    this.startDate,
    this.price = 0,
  });

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';
  bool get isExpiringSoon => daysRemaining <= 7 && daysRemaining > 0;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final endDateStr = json['endDate'] ?? json['end_date'];
    final startDateStr = json['startDate'] ?? json['start_date'];
    
    return Subscription(
      id: json['id'] ?? 0,
      planType: json['planType'] ?? json['plan_type'] ?? 'monthly',
      status: json['status'] ?? 'inactive',
      endDate: endDateStr != null ? DateTime.parse(endDateStr) : null,
      daysRemaining: json['daysRemaining'] ?? json['days_remaining'] ?? 0,
      autoRenew: json['autoRenew'] ?? json['auto_renew'] ?? false,
      startDate: startDateStr != null ? DateTime.parse(startDateStr) : null,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_type': planType,
      'status': status,
      'end_date': endDate?.toIso8601String(),
      'days_remaining': daysRemaining,
      'auto_renew': autoRenew,
      'start_date': startDate?.toIso8601String(),
      'price': price,
    };
  }
}
