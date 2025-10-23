import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';

class ScanReceiptModel extends ScanReceiptEntity {
  ScanReceiptModel({required super.successMessage, required super.items});

  ScanReceiptModel copyWith({
    String? successMessage,
    List<ScanReceiptItemEntity>? items,
  }) {
    return ScanReceiptModel(
      successMessage: successMessage ?? this.successMessage,
      items: items ?? this.items,
    );
  }
}
