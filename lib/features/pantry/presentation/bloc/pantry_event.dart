import 'package:foodkitchen/core/common/domain/entities/pantry.dart';

sealed class PantryEvent {}

final class PantryAddItemEvent extends PantryEvent {
  final Pantry pantry;
  PantryAddItemEvent({required this.pantry});
}

final class PantryAddScannedItemEvent extends PantryEvent {
  final Pantry pantry;
  PantryAddScannedItemEvent({required this.pantry});
}

final class GetPantryItemsEvent extends PantryEvent {
  final String kitchenId;
  GetPantryItemsEvent({required this.kitchenId});
}

final class ScanReceiptEvent extends PantryEvent {
  final String filePath;
  ScanReceiptEvent({required this.filePath});
}

final class PantryRequestItemEvent extends PantryEvent {
  final Pantry pantry;
  PantryRequestItemEvent({required this.pantry});
}

class IncrementItemEvent extends PantryEvent {
  final int index;
  IncrementItemEvent(this.index);
}

class DecrementItemEvent extends PantryEvent {
  final int index;
  DecrementItemEvent(this.index);
}

class ShowNotificationEvent extends PantryEvent {
  final int id;
  final String title;
  final String kitchenId;
  final String body;
  final String? payload;
  ShowNotificationEvent({
    required this.id,
    required this.body,
    required this.kitchenId,
    required this.title,
    this.payload,
  });
}

final class CreatePantryEvent extends PantryEvent {
  final String kitchenId;
  final List<String> pantries;
  CreatePantryEvent({required this.kitchenId, required this.pantries});
}

final class GetUserStorageAreaForPantryViewEvent extends PantryEvent {
  final String kitchenId;
  GetUserStorageAreaForPantryViewEvent(this.kitchenId);
}

final class DeletePantryEvent extends PantryEvent {
  final String kitchenId;
  final String pantryId;
  DeletePantryEvent({required this.kitchenId, required this.pantryId});
}

final class CartItemsEvent extends PantryEvent {
  final Pantry pantry;
  final int index;
  CartItemsEvent({required this.pantry, required this.index});
}

final class DeleteItemEvent extends PantryEvent {
  final Pantry pantry;
  DeleteItemEvent({required this.pantry});
}

final class UpdateItemEvent extends PantryEvent {
  final Pantry pantry;
  UpdateItemEvent({required this.pantry});
}
