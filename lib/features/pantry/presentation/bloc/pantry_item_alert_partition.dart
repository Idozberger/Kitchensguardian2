import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';

({List<PantryItemEntity> lowStock, List<PantryItemEntity> expiring})
partitionPantryItemsByAlerts(List<PantryItemEntity> items) {
  final lowStock = <PantryItemEntity>[];
  final expiring = <PantryItemEntity>[];

  for (final item in items) {
    if (item.stockStatus == "low_stock") {
      lowStock.add(item);
      continue;
    }
    if (item.expiryStatus == "expiring_soon") {
      expiring.add(item);
      continue;
    }
  }

  return (lowStock: lowStock, expiring: expiring);
}
