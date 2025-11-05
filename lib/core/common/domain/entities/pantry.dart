import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';

class Pantry {
  final String kitchenId;
  final List<PantryItemEntity> items;
  Pantry({required this.kitchenId, required this.items});
}
