class ScanReceiptItemEntity {
  final String name;
  final String unit;
  final String amount;
  final String expireDate;
  final String group;

  /// Resolved shared_ingredients catalog icon URL, or empty if the scan
  /// hasn't matched this item to a catalog entry (yet).
  final String thumbnail;
  final bool needsReview;

  /// KG-16: estimated per-unit weight in grams for discrete/count goods
  /// (e.g. "1 can ~400g"). Null for weight/volume units and fresh produce.
  final double? estimatedWeightGrams;
  final String? weightBasis;

  ScanReceiptItemEntity({
    required this.name,
    required this.unit,
    required this.amount,
    required this.expireDate,
    required this.group,
    required this.thumbnail,
    required this.needsReview,
    this.estimatedWeightGrams,
    this.weightBasis,
  });
}
