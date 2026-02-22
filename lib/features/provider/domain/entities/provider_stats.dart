class ProviderStats {
  final int pendingRequests;
  final int completedRequests;
  final double totalEarnings;

  const ProviderStats({
    required this.pendingRequests,
    required this.completedRequests,
    required this.totalEarnings,
  });

  factory ProviderStats.fromJson(Map<String, dynamic> json) {
    return ProviderStats(
      pendingRequests: json['pendingRequests'] ?? json['pending_requests'] ?? 0,
      completedRequests: json['completedRequests'] ?? json['completed_requests'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? json['earnings']?['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendingRequests': pendingRequests,
      'completedRequests': completedRequests,
      'totalEarnings': totalEarnings,
    };
  }
}
