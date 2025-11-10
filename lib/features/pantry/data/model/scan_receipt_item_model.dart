import 'dart:typed_data';

import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';

class ScanReceiptItemModel extends ScanReceiptItemEntity {
  ScanReceiptItemModel({
    required super.name,
    required super.unit,
    required super.amount,
    required super.expireDate,
    required super.thumbnail,
  });

  factory ScanReceiptItemModel.fromJson(Map<String, dynamic>? json) {
    return ScanReceiptItemModel(
      name: json?['name'] as String? ?? '',
      unit: json?['unit'] as String? ?? 'Unit',
      amount: json?['amount'] as String? ?? '0',
      expireDate: json?['expiry_date'] as String? ?? '0',
      thumbnail: json?['thumbnail'] as Uint8List? ?? Uint8List(0),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'amount': amount,
      'expiry_date': expireDate,
      'thumbnail': thumbnail,
    };
  }

  ScanReceiptItemModel copyWith({
    String? name,
    String? unit,
    String? amount,
    String? expireDate,
    Uint8List? thumbnail,
  }) {
    return ScanReceiptItemModel(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      expireDate: expireDate ?? this.expireDate,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
