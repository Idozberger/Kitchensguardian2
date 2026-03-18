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
  });
}
