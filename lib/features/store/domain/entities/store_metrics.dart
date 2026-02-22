class StoreMetrics {
  final int storeId;
  final double salesToday;
  final double salesMonth;
  final int ordersCompletedToday;
  final int ordersCompletedMonth;
  final double cashPending;
  final double avgTicket;

  StoreMetrics({
    required this.storeId,
    required this.salesToday,
    required this.salesMonth,
    required this.ordersCompletedToday,
    required this.ordersCompletedMonth,
    required this.cashPending,
    required this.avgTicket,
  });

  factory StoreMetrics.fromJson(Map<String, dynamic> json) {
    return StoreMetrics(
      storeId: json['storeId'] ?? json['store_id'] ?? 0,
      salesToday: (json['salesToday'] ?? json['sales_today'] ?? 0).toDouble(),
      salesMonth: (json['salesMonth'] ?? json['sales_month'] ?? 0).toDouble(),
      ordersCompletedToday: json['ordersCompletedToday'] ?? json['orders_completed_today'] ?? 0,
      ordersCompletedMonth: json['ordersCompletedMonth'] ?? json['orders_completed_month'] ?? 0,
      cashPending: (json['cashPending'] ?? json['cash_pending'] ?? 0).toDouble(),
      avgTicket: (json['avgTicket'] ?? json['avg_ticket'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'salesToday': salesToday,
      'salesMonth': salesMonth,
      'ordersCompletedToday': ordersCompletedToday,
      'ordersCompletedMonth': ordersCompletedMonth,
      'cashPending': cashPending,
      'avgTicket': avgTicket,
    };
  }
}
