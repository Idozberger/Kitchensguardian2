import 'package:foodkitchen/features/home/domain/entities/pantries_items.dart';

class PantriesItemsModel extends PantriesItemsEntity {
  PantriesItemsModel({
    required super.name,
    required super.quantity,
    required super.unit,
    required super.group,
  });

  factory PantriesItemsModel.fromJson(Map<String, dynamic> json) {
    return PantriesItemsModel(
      name: json['name'] as String,
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] as String,
      group: json['group'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'unit': unit, 'group': group};
  }

  factory PantriesItemsModel.fromEntity(PantriesItemsEntity entity) {
    return PantriesItemsModel(
      name: entity.name,
      quantity: entity.quantity,
      unit: entity.unit,
      group: entity.group,
    );
  }
}
