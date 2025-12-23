import 'package:foodkitchen/features/home/domain/entities/pantry_items.dart';

class PantriesItemsModel extends PantriesItemsEntity {
  PantriesItemsModel({
    required super.name,
    required super.quantity,
    required super.unit,
    required super.group,
    required super.expireDate,
    required super.expiryStatus,
    required super.itemId,
    required super.stockStatus,
    required super.thumbnail,
  });

  factory PantriesItemsModel.fromJson(Map<String, dynamic> json) {
    return PantriesItemsModel(
      thumbnail: "",
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] is int || json['quantity'] is double)
          ? (json['quantity'] as num).toDouble()
          : 0.0,
      unit: json['unit']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      expireDate: json['expiry_date']?.toString() ?? '',

      expiryStatus: json['expiry_status']?.toString() ?? '',
      stockStatus: json['stock_status']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'unit': unit, 'group': group};
  }

  factory PantriesItemsModel.fromEntity(PantriesItemsEntity entity) {
    return PantriesItemsModel(
      name: entity.name,
      quantity: entity.quantity,
      unit: entity.unit,
      group: entity.group,
      expireDate: entity.expireDate,
      expiryStatus: entity.expiryStatus,
      itemId: entity.itemId,
      stockStatus: entity.stockStatus,
      thumbnail: entity.thumbnail,
    );
  }
}
