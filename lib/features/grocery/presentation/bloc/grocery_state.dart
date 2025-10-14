import 'package:foodkitchen/features/grocery/domain/entities/requested_item.dart';

sealed class GroceryState {
  const GroceryState();
}

final class GroceryInitial extends GroceryState {}

final class GroceryLoading extends GroceryState {}

final class GrocerySuccess extends GroceryState {
  final String successMessage;
  GrocerySuccess(this.successMessage);
}

final class GroceryFailure extends GroceryState {
  final String message;
  const GroceryFailure(this.message);
}

final class RequestedGroceryLoaded extends GroceryState {
  final List<RequestedItemEntity> requestedItemsList;
  const RequestedGroceryLoaded(this.requestedItemsList);
}
