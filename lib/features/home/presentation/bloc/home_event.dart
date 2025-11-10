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

final class GetAllWeeklyPlansEventForHome extends HomeEvent {}

final class ResetHomeStateEvent extends HomeEvent {}

final class GetUserStorageAreaEvent extends HomeEvent {
  final String kitchenId;
  GetUserStorageAreaEvent(this.kitchenId);
}
