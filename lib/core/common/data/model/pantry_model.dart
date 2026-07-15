import 'dart:typed_data';

import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

class PantryModel extends Pantry {
  PantryModel({required super.kitchenId, required super.items});

  factory PantryModel.fromJson(Map<String, dynamic> json) {
    final Object? itemsRaw = json['items'];
    final List<dynamic> itemsList = itemsRaw is List<dynamic> ? itemsRaw : [];
    return PantryModel(
      kitchenId: readJsonString(json, 'kitchen_id'),
      items: itemsList
          .map(
            (Object? item) =>
                PantryItemModel.fromJson(jsonObjectFromResponseData(item)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kitchen_id': kitchenId,
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
    items: entity.items.map(PantryItemModel.fromEntity).toList(),
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
    super.iconUrl,
  });

  factory PantryItemModel.fromJson(Map<String, dynamic> json) {
    // `thumbnail` is a backend path (e.g. `/api/ingredient-icons/7`) that
    // redirects to the actual file — never base64, never decode it.
    final String thumbnailPath = json['thumbnail']?.toString() ?? '';
    String resolvedIconUrl = readJsonString(json, 'icon_url');

    if (resolvedIconUrl.isEmpty && thumbnailPath.startsWith('/')) {
      resolvedIconUrl = '${AppConstants.baseUrl}$thumbnailPath';
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
      thumbnailBytes: Uint8List(0),
      expiryStatus: json['expiry_status']?.toString() ?? '',
      stockStatus: json['stock_status']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      addedAt:
          DateTime.tryParse(readJsonString(json, 'added_at')) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      iconUrl: resolvedIconUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'group': group,
      "expiry_date": expireDate,
      "thumbnail": thumbnail,
      "expiry_status": expiryStatus,
      "stock_status": stockStatus,
      "item_id": itemId,
      "added_at": addedAt.toString(),
      "icon_url": iconUrl,
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
      iconUrl: entity.iconUrl,
    );
  }
}
