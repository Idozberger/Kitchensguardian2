class RequestedItemEntity {
  final String id;
  final String bucketType;
  final String itemId;
  final String kitchenId;
  final String name;
  final String quantity;
  final String unit;
  final String userId;
  final DateTime requestedAt;

  RequestedItemEntity({
    required this.id,
    required this.bucketType,
    required this.itemId,
    required this.kitchenId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.userId,
    required this.requestedAt,
  });
}
