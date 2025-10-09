sealed class HomeEvent {}

class CreateKitchenEvent extends HomeEvent {
  final String kitchenName;
  CreateKitchenEvent(this.kitchenName);
}

class JoinKitchenEvent extends HomeEvent {
  final String invitationCode;
  JoinKitchenEvent(this.invitationCode);
}
