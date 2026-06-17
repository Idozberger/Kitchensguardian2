import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_type.dart';

class PantryTypeModel extends PantryTypeEntity {
  PantryTypeModel({required super.id, required super.name});
  factory PantryTypeModel.fromJson(Map<String, dynamic> json) {
    return PantryTypeModel(
      id: readJsonString(json, 'id'),
      name: readJsonString(json, 'name'),
    );
  }
}
