class Earnings {
  final String period;
  final EarningsSummary summary;
  final List<EarningsEntry> entries;
  final String currency;

  const Earnings({
    required this.period,
    required this.summary,
    required this.entries,
    this.currency = 'MXN',
  });

  factory Earnings.fromJson(Map<String, dynamic> json) {
    return Earnings(
      period: json['period'] ?? 'month',
      summary: EarningsSummary.fromJson(json['summary'] ?? {}),
      entries: (json['entries'] as List?)
              ?.map((e) => EarningsEntry.fromJson(e))
              .toList() ??
          [],
      currency: json['currency'] ?? 'MXN',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'summary': summary.toJson(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'currency': currency,
    };
  }
}

class EarningsSummary {
  final double grossAmount;
  final double platformFee;
  final double netAmount;
  final int requestsCount;
  final double avgPerRequest;
  final double feePercentage;

  const EarningsSummary({
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
    required this.requestsCount,
    required this.avgPerRequest,
    required this.feePercentage,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      grossAmount: (json['grossAmount'] ?? json['gross_amount'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? json['platform_fee'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? json['net_amount'] ?? 0).toDouble(),
      requestsCount: json['requestsCount'] ?? json['requests_count'] ?? 0,
      avgPerRequest: (json['avgPerRequest'] ?? json['avg_per_request'] ?? 0).toDouble(),
      feePercentage: (json['feePercentage'] ?? json['fee_percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grossAmount': grossAmount,
      'platformFee': platformFee,
      'netAmount': netAmount,
      'requestsCount': requestsCount,
      'avgPerRequest': avgPerRequest,
      'feePercentage': feePercentage,
    };
  }
}

class EarningsEntry {
  final int id;
  final int requestId;
  final double grossAmount;
  final double platformFee;
  final double netAmount;
  final String origin;
  final String destination;
  final DateTime completedAt;

  const EarningsEntry({
    required this.id,
    required this.requestId,
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
    required this.origin,
    required this.destination,
    required this.completedAt,
  });

  factory EarningsEntry.fromJson(Map<String, dynamic> json) {
    return EarningsEntry(
      id: json['id'] ?? 0,
      requestId: json['requestId'] ?? json['request_id'] ?? 0,
      grossAmount: (json['grossAmount'] ?? json['gross_amount'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? json['platform_fee'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? json['net_amount'] ?? 0).toDouble(),
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      completedAt: DateTime.parse(json['completedAt'] ?? json['completed_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'grossAmount': grossAmount,
      'platformFee': platformFee,
      'netAmount': netAmount,
      'origin': origin,
      'destination': destination,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
