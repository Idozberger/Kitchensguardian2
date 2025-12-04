class ExpiringItemEntity {
  final String itemId;
  final String itemName;
  final double quantity;
  final String unit;
  final String expiryStatus;
  final String? group;

  const ExpiringItemEntity({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.expiryStatus,
    this.group,
  });
}
