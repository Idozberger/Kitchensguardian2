import 'package:foodkitchen/features/home/domain/entities/item_request.dart';

class ItemRequestModel extends ItemRequest {
  ItemRequestModel({
    required super.createdAt,
    super.expiryDate,
    required super.group,
    required super.kitchenId,
    required super.name,
    required super.quantity,
    super.rejectReason,
    required super.requestId,
    required super.requestedBy,
    required super.requesterName,
    super.reviewedAt,
    required super.status,
    super.thumbnail,
    required super.unit,
  });

  factory ItemRequestModel.fromJson(Map<String, dynamic> json) {
    return ItemRequestModel(
      createdAt: DateTime.parse(json['created_at'].toString()),
      expiryDate: json['expiry_date']?.toString(),
      group: json['group']?.toString() ?? '',
      kitchenId: json['kitchen_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num).toDouble(),
      rejectReason: json['reject_reason']?.toString(),
      requestId: json['request_id']?.toString() ?? '',
      requestedBy: json['requested_by'],
      requesterName: json['requester_name']?.toString() ?? '',
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'].toString())
          : null,
      status: json['status']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString(),
      unit: json['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'expiry_date': expiryDate,
      'group': group,
      'kitchen_id': kitchenId,
      'name': name,
      'quantity': quantity,
      'reject_reason': rejectReason,
      'request_id': requestId,
      'requested_by': requestedBy,
      'requester_name': requesterName,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'status': status,
      'thumbnail': thumbnail,
      'unit': unit,
    };
  }
}
