class ScannedItemEntity {
  final String area;
  final String? brand;
  final int confidence;
  final String expiryDate;
  final String name;
  final int quantity;
  final String recommendedStorage;
  final String tempId;
  final String unit;

  /// KG-16: estimated per-unit weight in grams for discrete/count goods
  /// (e.g. "1 can ~400g"). Null for weight/volume units and fresh produce.
  final double? estimatedWeightGrams;
  final String? weightBasis;

  const ScannedItemEntity({
    required this.area,
    this.brand,
    required this.confidence,
    required this.expiryDate,
    required this.name,
    required this.quantity,
    required this.recommendedStorage,
    required this.tempId,
    required this.unit,
    this.estimatedWeightGrams,
    this.weightBasis,
  });
}
