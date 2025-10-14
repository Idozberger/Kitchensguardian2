import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';

class ScanReceiptItemModel extends ScanReceiptItemEntity {
  ScanReceiptItemModel({
    required super.name,
    required super.unit,
    required super.amount,
  });

  factory ScanReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ScanReceiptItemModel(
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'unit': unit, 'amount': amount};
  }

  ScanReceiptItemModel copyWith({String? name, String? amount, String? unit}) {
    return ScanReceiptItemModel(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
    );
  }
}
