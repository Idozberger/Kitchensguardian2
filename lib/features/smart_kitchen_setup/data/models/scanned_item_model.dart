import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/scanned_item.dart';

class ScannedItemModel extends ScannedItemEntity {
  const ScannedItemModel({
    required super.area,
    super.brand,
    required super.confidence,
    required super.expiryDate,
    required super.name,
    required super.quantity,
    required super.recommendedStorage,
    required super.tempId,
    required super.unit,
    super.estimatedWeightGrams,
    super.weightBasis,
  });

  factory ScannedItemModel.fromJson(Map<String, dynamic> json) {
    return ScannedItemModel(
      area: json['area'] as String,
      brand: json['brand'] as String?,
      confidence: (json['confidence'] as num).toInt(),
      expiryDate: json['expiry_date'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      recommendedStorage: json['recommended_storage'] as String,
      tempId: json['temp_id'] as String,
      unit: json['unit'] as String,
      estimatedWeightGrams: (json['estimated_weight_grams'] as num?)
          ?.toDouble(),
      weightBasis: json['weight_basis'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'brand': brand,
      'confidence': confidence,
      'expiry_date': expiryDate,
      'name': name,
      'quantity': quantity,
      'recommended_storage': recommendedStorage,
      'temp_id': tempId,
      'unit': unit,
      'estimated_weight_grams': estimatedWeightGrams,
      'weight_basis': weightBasis,
    };
  }

  ScannedItemEntity toEntity() {
    return ScannedItemEntity(
      area: area,
      brand: brand,
      confidence: confidence,
      expiryDate: expiryDate,
      name: name,
      quantity: quantity,
      recommendedStorage: recommendedStorage,
      tempId: tempId,
      unit: unit,
      estimatedWeightGrams: estimatedWeightGrams,
      weightBasis: weightBasis,
    );
  }
}
