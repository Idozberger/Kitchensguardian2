class Pantry {
  final String kitchenId;
  final List<PantryItemEntity> items;
  Pantry({required this.kitchenId, required this.items});
}

class PantryItemEntity {
  final String name;
  final int quantity;
  final String unit;
  final String group;

  PantryItemEntity({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.group,
  });
}
