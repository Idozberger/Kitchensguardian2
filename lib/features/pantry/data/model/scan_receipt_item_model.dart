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
}
