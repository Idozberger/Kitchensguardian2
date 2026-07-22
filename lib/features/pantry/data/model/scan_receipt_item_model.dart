import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';

class ScanReceiptItemModel extends ScanReceiptItemEntity {
  ScanReceiptItemModel({
    required super.name,
    required super.unit,
    required super.amount,
    required super.expireDate,
    required super.thumbnail,
    required super.group,
    required super.needsReview,
    super.estimatedWeightGrams,
    super.weightBasis,
  });

  ScanReceiptItemModel copyWith({
    String? name,
    String? unit,
    String? amount,
    String? expireDate,
    String? group,
    String? thumbnail,
    bool? needsReview,
    double? estimatedWeightGrams,
    String? weightBasis,
  }) {
    return ScanReceiptItemModel(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      expireDate: expireDate ?? this.expireDate,
      thumbnail: thumbnail ?? this.thumbnail,
      group: group ?? this.group,
      needsReview: needsReview ?? this.needsReview,
      estimatedWeightGrams: estimatedWeightGrams ?? this.estimatedWeightGrams,
      weightBasis: weightBasis ?? this.weightBasis,
    );
  }
}
