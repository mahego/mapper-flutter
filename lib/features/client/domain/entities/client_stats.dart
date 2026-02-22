class ClientStats {
  final int totalRequests;
  final int activeRequests;
  final int completedRequests;
  final double totalSpent;
  final int pendingRequests;

  const ClientStats({
    required this.totalRequests,
    required this.activeRequests,
    required this.completedRequests,
    required this.totalSpent,
    required this.pendingRequests,
  });

  factory ClientStats.fromJson(Map<String, dynamic> json) {
    return ClientStats(
      totalRequests: json['totalRequests'] ?? json['total_requests'] ?? 0,
      activeRequests: json['activeRequests'] ?? json['active_requests'] ?? 0,
      completedRequests: json['completedRequests'] ?? json['completed_requests'] ?? 0,
      totalSpent: (json['totalSpent'] ?? json['total_spent'] ?? 0.0).toDouble(),
      pendingRequests: json['pendingRequests'] ?? json['pending_requests'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRequests': totalRequests,
      'activeRequests': activeRequests,
      'completedRequests': completedRequests,
      'totalSpent': totalSpent,
      'pendingRequests': pendingRequests,
    };
  }
}
