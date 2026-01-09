class ConsumptionConfirmation {
  final String id;
  final String itemName;
  final double quantity;
  final String unit;
  final DateTime addedAt;
  final DateTime predictedDepletionDate;
  final String status;
  final DateTime expiresAt;

  ConsumptionConfirmation({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.addedAt,
    required this.predictedDepletionDate,
    required this.status,
    required this.expiresAt,
  });
}
