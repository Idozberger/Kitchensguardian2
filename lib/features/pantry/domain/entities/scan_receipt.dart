import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';

class ScanReceiptEntity {
  final String successMessage;
  final List<ScanReceiptItemEntity> items;

  ScanReceiptEntity({required this.successMessage, required this.items});
}
