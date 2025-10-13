import 'package:foodkitchen/features/pantry/domain/entities/pantry.dart';

sealed class PantryEvent {}

final class PantryAddItemEvent extends PantryEvent {
  final Pantry pantry;
  PantryAddItemEvent({required this.pantry});
}
