import 'package:foodkitchen/features/pantry/domain/entities/pantry.dart';
import 'package:foodkitchen/features/pantry/domain/entities/pantry_item.dart';

class PantryModel extends Pantry {
  PantryModel({required super.kitchenId, required super.items});

  factory PantryModel.fromJson(Map<String, dynamic> json) {
    return PantryModel(
      kitchenId: json['kitchen_id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => PantryItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kitchen_id': kitchenId,
      'items': items.map((item) {
        if (item is PantryItemModel) {
          return item.toJson();
        }
        return {
          'name': item.name,
          'quantity': item.quantity,
          'unit': item.unit,
          'group': item.group,
        };
      }).toList(),
    };
  }

  factory PantryModel.fromEntity(Pantry entity) => PantryModel(
    kitchenId: entity.kitchenId,
    items: entity.items
        .map((item) => PantryItemModel.fromEntity(item))
        .toList(),
  );
}

class PantryItemModel extends PantryItemEntity {
  PantryItemModel({
    required super.name,
    required super.quantity,
    required super.unit,
    required super.group,
  });

  factory PantryItemModel.fromJson(Map<String, dynamic> json) {
    return PantryItemModel(
      name: json['name'] as String,
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] as String,
      group: json['group'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'unit': unit, 'group': group};
  }

  factory PantryItemModel.fromEntity(PantryItemEntity entity) {
    return PantryItemModel(
      name: entity.name,
      quantity: entity.quantity,
      unit: entity.unit,
      group: entity.group,
    );
  }
}
