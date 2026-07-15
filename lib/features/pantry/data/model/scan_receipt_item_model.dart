import 'dart:typed_data';

import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';

class ScanReceiptItemModel extends ScanReceiptItemEntity {
  ScanReceiptItemModel({
    required super.name,
    required super.unit,
    required super.amount,
    required super.expireDate,
    required super.thumbnail,
    required super.group,
    required super.needsReview,
  });

  factory ScanReceiptItemModel.fromJson(Map<String, dynamic>? json) {
    return ScanReceiptItemModel(
      name: json?['name'] as String? ?? '',
      unit: json?['unit'] as String? ?? 'unit',
      amount: json?['quantity'] as String? ?? '0',
      expireDate: json?['expiry_date'] as String? ?? '0',
      thumbnail: json?['thumbnail'] as Uint8List? ?? Uint8List(0),
      group: json?['storage'] as String? ?? 'Refrigerator',
      needsReview: json?['needs_review'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'quantity': amount,
      'expiry_date': expireDate,
      'thumbnail': thumbnail,
      'storage': group,
      'needs_review': needsReview,
    };
  }

  ScanReceiptItemModel copyWith({
    String? name,
    String? unit,
    String? amount,
    String? expireDate,
    Uint8List? thumbnail,
    String? group,
    bool? needsReview,
  }) {
    return ScanReceiptItemModel(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      expireDate: expireDate ?? this.expireDate,
      thumbnail: thumbnail ?? this.thumbnail,
      group: group ?? this.group,
      needsReview: needsReview ?? this.needsReview,
    );
  }
}
