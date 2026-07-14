class RequestedItemEntity {
  final String id;
  final bool checked;
  final String bucketType;
  final String itemId;
  final String kitchenId;
  final String name;
  final String quantity;
  final String unit;
  final String userId;
  final DateTime requestedAt;
  final String iconUrl;

  RequestedItemEntity({
    required this.id,
    required this.bucketType,
    required this.itemId,
    required this.kitchenId,
    required this.checked,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.userId,
    required this.requestedAt,
    this.iconUrl = '',
  });
}
