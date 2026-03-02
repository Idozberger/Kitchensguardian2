class ItemRequest {
  final DateTime createdAt;
  final String? expiryDate;
  final String group;
  final String kitchenId;
  final String name;
  final double quantity;
  final String? rejectReason;
  final String requestId;
  final String requestedBy;
  final String requesterName;
  final DateTime? reviewedAt;
  final String status;
  final String? thumbnail;
  final String unit;

  ItemRequest({
    required this.createdAt,
    this.expiryDate,
    required this.group,
    required this.kitchenId,
    required this.name,
    required this.quantity,
    this.rejectReason,
    required this.requestId,
    required this.requestedBy,
    required this.requesterName,
    this.reviewedAt,
    required this.status,
    this.thumbnail,
    required this.unit,
  });
}
