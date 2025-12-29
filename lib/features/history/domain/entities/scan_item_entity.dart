import 'dart:typed_data';

class ScanItemEntity {
  final String amount;
  final String name;
  final String unit;
  final Uint8List thumbnail;

  const ScanItemEntity({
    required this.amount,
    required this.name,
    required this.unit,
    required this.thumbnail,
  });
}
