import 'package:foodkitchen/features/grocery/domain/entities/requested_item.dart';

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
  });
  factory RequestedItemModel.fromJson(Map<String, dynamic> json) {
    return RequestedItemModel(
      id: json['_id'] ?? '',
      bucketType: json['bucket_type'] ?? '',
      itemId: json['item_id'] ?? '',
      kitchenId: json['kitchen_id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? "0",
      unit: json['unit'] ?? '',
      userId: json['user_id'] ?? '',
      requestedAt:
          DateTime.tryParse(json['requested_at'] ?? '') ?? DateTime.now(),
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
      'requested_at': requestedAt.toIso8601String(),
    };
  }
}
