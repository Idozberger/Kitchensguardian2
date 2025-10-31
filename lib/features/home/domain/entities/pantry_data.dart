import 'package:foodkitchen/features/home/domain/entities/pantry_items.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_type.dart';

class PantriesDataEntity {
  final List<PantriesItemsEntity> items;
  final List<PantryTypeEntity> pantryTypes;

  PantriesDataEntity({required this.items, required this.pantryTypes});
}
