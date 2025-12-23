class PantriesItemsEntity {
  final String name;
  final double quantity;
  final String unit;
  final String group;
  final String expireDate;
  final String thumbnail;
  final String expiryStatus;
  final String stockStatus;
  final String itemId;

  PantriesItemsEntity({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.group,
    required this.expireDate,
    required this.thumbnail,
    required this.expiryStatus,
    required this.stockStatus,
    required this.itemId,
  });
}
