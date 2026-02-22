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
      grossAmount: (json['gross_amount'] ?? 0).toDouble(),
      platformFee: (json['platform_fee'] ?? 0).toDouble(),
      netAmount: (json['net_amount'] ?? 0).toDouble(),
      requestsCount: json['requests_count'] ?? 0,
      avgPerRequest: (json['avg_per_request'] ?? 0).toDouble(),
      feePercentage: (json['fee_percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gross_amount': grossAmount,
      'platform_fee': platformFee,
      'net_amount': netAmount,
      'requests_count': requestsCount,
      'avg_per_request': avgPerRequest,
      'fee_percentage': feePercentage,
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
      requestId: json['request_id'] ?? 0,
      grossAmount: (json['gross_amount'] ?? 0).toDouble(),
      platformFee: (json['platform_fee'] ?? 0).toDouble(),
      netAmount: (json['net_amount'] ?? 0).toDouble(),
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      completedAt: DateTime.parse(json['completed_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'gross_amount': grossAmount,
      'platform_fee': platformFee,
      'net_amount': netAmount,
      'origin': origin,
      'destination': destination,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
