sealed class HomeEvent {}

class CreateKitchenEventForHome extends HomeEvent {
  final String kitchenName;
  CreateKitchenEventForHome(this.kitchenName);
}

class JoinKitchenEventForHome extends HomeEvent {
  final String invitationCode;
  JoinKitchenEventForHome(this.invitationCode);
}

final class GetAllRequestedItemsEvent extends HomeEvent {
  final String kitchenId;
  GetAllRequestedItemsEvent({required this.kitchenId});
}

final class RespondToItemRequestEvent extends HomeEvent {
  final String action;
  final String rejectReason;
  final String requestId;
  RespondToItemRequestEvent({
    required this.action,
    required this.rejectReason,
    required this.requestId,
  });
}

final class RespondToItemRejectRequestEvent extends HomeEvent {
  final String action;
  final String rejectReason;
  final String requestId;
  RespondToItemRejectRequestEvent({
    required this.action,
    required this.rejectReason,
    required this.requestId,
  });
}

final class GetPantriesItemsEventForHome extends HomeEvent {
  final String kitchenId;

  GetPantriesItemsEventForHome({required this.kitchenId});
}

final class GetAllWeeklyPlansEventForHome extends HomeEvent {}

final class ResetHomeStateEvent extends HomeEvent {}

final class GetUserStorageAreaEvent extends HomeEvent {
  final String kitchenId;
  GetUserStorageAreaEvent(this.kitchenId);
}

final class GenerateGroceryList extends HomeEvent {}

final class GetRecipeSuggestionEvent extends HomeEvent {
  final String kitchenId;
  GetRecipeSuggestionEvent(this.kitchenId);
}
