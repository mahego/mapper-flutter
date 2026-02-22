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
      pendingRequests: json['pending_requests'] ?? 0,
      completedRequests: json['completed_requests'] ?? 0,
      totalEarnings: (json['earnings']?['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending_requests': pendingRequests,
      'completed_requests': completedRequests,
      'earnings': {'total': totalEarnings},
    };
  }
}
