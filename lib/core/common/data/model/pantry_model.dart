import 'dart:convert';
import 'dart:typed_data';

import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';

class PantryModel extends Pantry {
  PantryModel({required super.kitchenId, required super.items});

  factory PantryModel.fromJson(Map<String, dynamic> json) {
    return PantryModel(
      kitchenId: json['kitchen_id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => PantryItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kitchen_id': kitchenId.toString(),
      'items': items.map((item) {
        if (item is PantryItemModel) {
          return item.toJson();
        }
        return {
          'name': item.name,
          'quantity': item.quantity,
          'unit': item.unit,
          'group': item.group,
        };
      }).toList(),
    };
  }

  factory PantryModel.fromEntity(Pantry entity) => PantryModel(
    kitchenId: entity.kitchenId,
    items: entity.items
        .map((item) => PantryItemModel.fromEntity(item))
        .toList(),
  );
}

class PantryItemModel extends PantryItemEntity {
  PantryItemModel({
    required super.name,
    required super.quantity,
    required super.unit,
    required super.group,
    required super.expireDate,
    required super.thumbnail,
    required super.expiryStatus,
    required super.stockStatus,
    required super.itemId,
    required super.thumbnailBytes,
    required super.addedAt,
  });

  factory PantryItemModel.fromJson(Map<String, dynamic> json) {
    String? thumbnailBase64 = json['thumbnail']?.toString();
    Uint8List? thumbnailBytes;

    if (thumbnailBase64 != null && thumbnailBase64.contains('base64,')) {
      try {
        final base64Image = thumbnailBase64.split('base64,').last;
        thumbnailBytes = base64Decode(base64Image);
      } catch (_) {
        thumbnailBytes = Uint8List(0);
      }
    }

    return PantryItemModel(
      thumbnail: "",
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] is int || json['quantity'] is double)
          ? (json['quantity'] as num).toDouble()
          : 0.0,
      unit: json['unit']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      expireDate: json['expiry_date']?.toString() ?? '',
      thumbnailBytes: thumbnailBytes ?? Uint8List(0),
      expiryStatus: json['expiry_status']?.toString() ?? '',
      stockStatus: json['stock_status']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      addedAt: DateTime.parse(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toString(),
      'quantity': quantity,
      'unit': unit.toString(),
      'group': group.toString(),
      "expiry_date": expireDate.toString(),
      "thumbnail": thumbnail,
      "expiry_status": expiryStatus.toString(),
      "stock_status": stockStatus.toString(),
      "item_id": itemId.toString(),
      "added_at": addedAt.toString(),
    };
  }

  factory PantryItemModel.fromEntity(PantryItemEntity entity) {
    return PantryItemModel(
      name: entity.name,
      thumbnailBytes: entity.thumbnailBytes,
      quantity: entity.quantity,
      unit: entity.unit,
      group: entity.group,
      expireDate: entity.expireDate,
      thumbnail: entity.thumbnail,
      expiryStatus: entity.expiryStatus,
      stockStatus: entity.stockStatus,
      itemId: entity.itemId,
      addedAt: entity.addedAt,
    );
  }
}
