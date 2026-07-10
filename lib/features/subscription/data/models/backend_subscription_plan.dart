/// Plan row from [GET /api/subscription/plans].
final class BackendSubscriptionPlan {
  const BackendSubscriptionPlan({
    required this.planId,
    required this.title,
    required this.priceDisplay,
    required this.priceAmount,
    required this.billingPeriod,
    this.currency = 'USD',
  });

  final String planId;
  final String title;
  final String priceDisplay;
  final double priceAmount;
  final String currency;

  /// `monthly` or `annual` (also accepts `yearly` from API).
  final String billingPeriod;

  bool get isMonthly {
    final p = billingPeriod.toLowerCase();
    return p == 'monthly' || p == 'month';
  }

  bool get isAnnual {
    final p = billingPeriod.toLowerCase();
    return p == 'annual' || p == 'yearly' || p == 'year';
  }

  factory BackendSubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return BackendSubscriptionPlan(
      planId: (json['plan_id'] as String?)?.trim() ?? '',
      title: (json['title'] as String?)?.trim() ?? '',
      priceDisplay: (json['price_display'] as String?)?.trim() ?? '',
      priceAmount: _readAmount(json['price_amount']),
      currency: (json['currency'] as String?)?.trim().isNotEmpty == true
          ? (json['currency'] as String).trim()
          : 'USD',
      billingPeriod: (json['billing_period'] as String?)?.trim() ?? '',
    );
  }

  static double _readAmount(Object? raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw.trim()) ?? 0;
    }
    return 0;
  }
}
