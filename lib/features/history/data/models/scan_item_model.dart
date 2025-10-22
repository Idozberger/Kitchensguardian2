import 'package:foodkitchen/features/history/domain/entities/scan_item_entity.dart';

class ScanItemModel extends ScanItemEntity {
  ScanItemModel({
    required super.amount,
    required super.name,
    required super.unit,
  });
  factory ScanItemModel.fromJson(Map<String, dynamic> json) {
    return ScanItemModel(
      amount: json['amount'].toString() ?? '',
      name: json['name'].toString() ?? '',
      unit: json['unit'].toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'name': name,
    'unit': unit,
  };
}
