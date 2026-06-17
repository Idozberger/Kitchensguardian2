import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/services/notifications/pantry_stock_notifications.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_items.dart';

Future<void> scheduleHomePantryNotifications({
  required UserCubit userCubit,
  required List<PantriesItemsEntity> lowStockItems,
  required List<PantriesItemsEntity> expiringItems,
}) {
  return schedulePantryStockNotifications(
    userCubit: userCubit,
    lowStockItems: lowStockItems.map(_toPantryItemEntity).toList(),
    expiringItems: expiringItems.map(_toPantryItemEntity).toList(),
  );
}

PantryItemEntity _toPantryItemEntity(PantriesItemsEntity e) {
  return PantryItemEntity(
    name: e.name,
    quantity: e.quantity,
    unit: e.unit,
    group: e.group,
    expireDate: e.expireDate,
    thumbnail: e.thumbnail,
    expiryStatus: e.expiryStatus,
    stockStatus: e.stockStatus,
    itemId: e.itemId,
  );
}
