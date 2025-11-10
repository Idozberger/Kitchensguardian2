import 'dart:typed_data';

class ScanReceiptItemEntity {
  final String name;
  final String unit;
  final String amount;
  final String expireDate;
  final Uint8List thumbnail;

  ScanReceiptItemEntity({
    required this.name,
    required this.unit,
    required this.amount,
    required this.expireDate,
    required this.thumbnail,
  });
}
