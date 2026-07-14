import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

class RequestedItemModel extends RequestedItemEntity {
  RequestedItemModel({
    required super.id,
    required super.bucketType,
    required super.itemId,
    required super.kitchenId,
    required super.name,
    required super.quantity,
    required super.unit,
    required super.userId,
    required super.requestedAt,
    required super.checked,
    super.iconUrl,
  });

  factory RequestedItemModel.fromJson(Map<String, dynamic> json) {
    return RequestedItemModel(
      id: json['_id']?.toString() ?? '',
      bucketType: json['bucket_type']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      kitchenId: json['kitchen_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? "0",
      unit: json['unit']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      checked: json['checked'] is bool
          ? json['checked'] as bool
          : json['checked']?.toString().toLowerCase() == 'true',
      requestedAt:
          DateTime.tryParse(json['requested_at']?.toString() ?? '') ??
          DateTime.now(),
      iconUrl: readJsonString(json, 'icon_url'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bucket_type': bucketType,
      'item_id': itemId,
      'kitchen_id': kitchenId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'user_id': userId,
      'checked': checked,
      'requested_at': requestedAt.toIso8601String(),
      'icon_url': iconUrl,
    };
  }
}
