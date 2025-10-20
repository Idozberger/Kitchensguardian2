sealed class GroceryEvent {}

class RequestedGroceryEvent extends GroceryEvent {
  final String kitchenId;

  RequestedGroceryEvent({required this.kitchenId});
}

class UpdateBucketTypeEvent extends GroceryEvent {
  final String kitchenId;
  final List<String> itemIds;
  final String bucketType;

  UpdateBucketTypeEvent({
    required this.kitchenId,
    required this.itemIds,
    required this.bucketType,
  });
}

class DeleteKitchenItemsEvent extends GroceryEvent {
  final String kitchenId;
  final List<String> itemIds;

  DeleteKitchenItemsEvent({required this.kitchenId, required this.itemIds});
}

class AddMylistToInventoryEvent extends GroceryEvent {
  final String kitchenId;

  AddMylistToInventoryEvent({required this.kitchenId});
}

class GetAiGeneratedItemsEvent extends GroceryEvent {
  final String kitchenId;

  GetAiGeneratedItemsEvent({required this.kitchenId});
}
