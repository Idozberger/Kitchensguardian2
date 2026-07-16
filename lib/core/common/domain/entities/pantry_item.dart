import 'dart:typed_data';

class PantryItemEntity {
  final String name;
  final double quantity;
  final String unit;
  final String group;
  final String expireDate;
  final String thumbnail;
  final Uint8List? thumbnailBytes;
  final String expiryStatus;
  final String stockStatus;
  final String itemId;
  final DateTime? addedAt;
  final String iconUrl;
  final String? sharedIngredientId;

  PantryItemEntity({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.group,
    required this.expireDate,
    required this.thumbnail,
    required this.expiryStatus,
    required this.stockStatus,
    this.thumbnailBytes,
    required this.itemId,
    this.addedAt,
    this.iconUrl = '',
    this.sharedIngredientId,
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
      'iconUrl': iconUrl,
    };
  }
}
