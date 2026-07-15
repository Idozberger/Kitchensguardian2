import 'dart:typed_data';

class ScanReceiptItemEntity {
  final String name;
  final String unit;
  final String amount;
  final String expireDate;
  final String group;
  final Uint8List thumbnail;
  final bool needsReview;

  ScanReceiptItemEntity({
    required this.name,
    required this.unit,
    required this.amount,
    required this.expireDate,
    required this.group,
    required this.thumbnail,
    required this.needsReview,
  });
}
