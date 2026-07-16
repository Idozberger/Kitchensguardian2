class ScanReceiptItemEntity {
  final String name;
  final String unit;
  final String amount;
  final String expireDate;
  final String group;

  /// Raw base64 thumbnail payload from the scan API, left un-decoded.
  /// Decode lazily at render time (see `PantryItem.displayBytes`) instead of
  /// eagerly for every item — a receipt can have 50-100+ items.
  final String thumbnail;
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
