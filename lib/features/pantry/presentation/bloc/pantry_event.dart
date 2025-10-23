import 'package:foodkitchen/core/common/entities/pantry.dart';

sealed class PantryEvent {}

final class PantryAddItemEvent extends PantryEvent {
  final Pantry pantry;
  PantryAddItemEvent({required this.pantry});
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
