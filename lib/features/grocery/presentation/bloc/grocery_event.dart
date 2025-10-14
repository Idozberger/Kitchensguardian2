sealed class GroceryEvent {}

final class RequestedGroceryEvent extends GroceryEvent {
  final String kitchenId;

  RequestedGroceryEvent({required this.kitchenId});
}
