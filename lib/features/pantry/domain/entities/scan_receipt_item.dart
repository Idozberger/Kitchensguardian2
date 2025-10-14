class ScanReceiptItemEntity {
  String name;
  String unit;
  String amount;

  ScanReceiptItemEntity({
    required this.name,
    required this.unit,
    required this.amount,
  });
  ScanReceiptItemEntity copyWith({String? name, String? unit, String? amount}) {
    return ScanReceiptItemEntity(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
    );
  }
}
