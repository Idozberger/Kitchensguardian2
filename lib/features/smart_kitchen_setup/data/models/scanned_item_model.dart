import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/scanned_item.dart';

class ScannedItemModel extends ScannedItemEntity {
  const ScannedItemModel({
    required super.area,
    super.brand,
    required super.confidence,
    required super.expiryDate,
    required super.name,
    required super.needsReview,
    required super.quantity,
    required super.recommendedStorage,
    required super.tempId,
    required super.unit,
    super.sharedIngredientId,
    super.libraryMatch,
    super.estimatedWeightGrams,
    super.weightBasis,
  });

  factory ScannedItemModel.fromJson(Map<String, dynamic> json) {
    final sharedId = json['shared_ingredient_id'];
    return ScannedItemModel(
      area: readJsonString(json, 'area'),
      brand: json['brand']?.toString(),
      confidence: (json['confidence'] as num?)?.toInt() ?? 0,
      expiryDate: readJsonString(json, 'expiry_date'),
      name: readJsonString(json, 'name'),
      needsReview: readJsonBool(json, 'needs_review'),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      recommendedStorage: readJsonString(json, 'recommended_storage'),
      tempId: readJsonString(json, 'temp_id'),
      unit: readJsonString(json, 'unit'),
      sharedIngredientId: sharedId?.toString(),
      libraryMatch: json['library_match']?.toString(),
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
      'needs_review': needsReview,
      'quantity': quantity,
      'recommended_storage': recommendedStorage,
      'temp_id': tempId,
      'unit': unit,
      if (sharedIngredientId != null)
        'shared_ingredient_id':
            int.tryParse(sharedIngredientId!) ?? sharedIngredientId,
      if (libraryMatch != null) 'library_match': libraryMatch,
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
      needsReview: needsReview,
      quantity: quantity,
      recommendedStorage: recommendedStorage,
      tempId: tempId,
      unit: unit,
      sharedIngredientId: sharedIngredientId,
      libraryMatch: libraryMatch,
      estimatedWeightGrams: estimatedWeightGrams,
      weightBasis: weightBasis,
    );
  }
}
