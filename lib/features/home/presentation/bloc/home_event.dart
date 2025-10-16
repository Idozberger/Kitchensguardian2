sealed class HomeEvent {}

class CreateKitchenEventForHome extends HomeEvent {
  final String kitchenName;
  CreateKitchenEventForHome(this.kitchenName);
}

class JoinKitchenEventForHome extends HomeEvent {
  final String invitationCode;
  JoinKitchenEventForHome(this.invitationCode);
}

final class GetPantriesItemsEventForHome extends HomeEvent {
  final String kitchenId;
  GetPantriesItemsEventForHome({required this.kitchenId});
}
