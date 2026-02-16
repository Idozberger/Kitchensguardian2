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
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'group': group,
      'expireDate': expireDate,
      'thumbnail': thumbnail,
      'expiryStatus': expiryStatus,
      'stockStatus': stockStatus,
      'itemId': itemId,
    };
  }
}
