import 'package:foodkitchen/features/dashboard/domain/entities/consumption_confirmation.dart';

class ConsumptionConfirmationModel extends ConsumptionConfirmation {
  ConsumptionConfirmationModel({
    required super.id,
    required super.itemName,
    required super.quantity,
    required super.unit,
    required super.addedAt,
    required super.predictedDepletionDate,
    required super.status,
    required super.expiresAt,
  });

  factory ConsumptionConfirmationModel.fromJson(Map<String, dynamic> json) {
    return ConsumptionConfirmationModel(
      id: json['confirmation_id'] as String,
      itemName: json['item_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      addedAt: DateTime.parse(json['added_at'] as String),
      predictedDepletionDate: DateTime.parse(
        json['predicted_depletion_date'] as String,
      ),
      status: (json['status'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confirmation_id': id,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'added_at': addedAt.toIso8601String(),
      'predicted_depletion_date': predictedDepletionDate.toIso8601String(),
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  factory ConsumptionConfirmationModel.fromEntity(
    ConsumptionConfirmation entity,
  ) {
    return ConsumptionConfirmationModel(
      id: entity.id,
      itemName: entity.itemName,
      quantity: entity.quantity,
      unit: entity.unit,
      addedAt: entity.addedAt,
      predictedDepletionDate: entity.predictedDepletionDate,
      status: entity.status,
      expiresAt: entity.expiresAt,
    );
  }
}
