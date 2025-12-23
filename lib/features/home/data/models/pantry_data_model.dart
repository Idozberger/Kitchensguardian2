import 'package:foodkitchen/features/home/data/models/pantries_item_model.dart';
import 'package:foodkitchen/features/home/data/models/pantry_type_model.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';

class PantriesDataModel extends PantriesDataEntity {
  PantriesDataModel({required super.items, required super.pantryTypes});

  factory PantriesDataModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? [])
        .map((e) => PantriesItemsModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pantryTypes = (json['pantry_types'] as List? ?? [])
        .map((e) => PantryTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PantriesDataModel(items: items, pantryTypes: pantryTypes);
  }
}
