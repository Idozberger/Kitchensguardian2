import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';

class ScanReceipt {
  final String successMessage;
  final List<ScanReceiptItemEntity> items;

  ScanReceipt({required this.successMessage, required this.items});

  ScanReceipt copyWith({
    String? successMessage,
    List<ScanReceiptItemEntity>? items,
  }) {
    return ScanReceipt(
      successMessage: successMessage ?? this.successMessage,
      items: items ?? this.items,
    );
  }
}
