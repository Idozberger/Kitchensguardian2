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

  factory ScanReceiptItemModel.fromJson(Map<String, dynamic>? json) {
    return ScanReceiptItemModel(
      name: json?['name'] as String? ?? '',
      unit: json?['unit'] as String? ?? 'unit',
      amount: json?['quantity'] as String? ?? '0',
      expireDate: json?['expiry_date'] as String? ?? '0',
      thumbnail: json?['thumbnail'] as String? ?? '',
      group: json?['storage'] as String? ?? 'Refrigerator',
      needsReview: json?['needs_review'] as bool? ?? false,
      estimatedWeightGrams: (json?['estimated_weight_grams'] as num?)
          ?.toDouble(),
      weightBasis: json?['weight_basis'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'quantity': amount,
      'expiry_date': expireDate,
      'thumbnail': thumbnail,
      'storage': group,
      'needs_review': needsReview,
      'estimated_weight_grams': estimatedWeightGrams,
      'weight_basis': weightBasis,
    };
  }

  ScanReceiptItemModel copyWith({
    String? name,
    String? unit,
    String? amount,
    String? expireDate,
    String? thumbnail,
    String? group,
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
