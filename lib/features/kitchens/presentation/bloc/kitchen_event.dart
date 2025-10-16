import 'package:equatable/equatable.dart';

abstract class KitchenEvent extends Equatable {
  const KitchenEvent();

  @override
  List<Object?> get props => [];
}

class FetchKitchens extends KitchenEvent {}

class JoinKitchen extends KitchenEvent {
  final String invitationCode;

  const JoinKitchen(this.invitationCode);

  @override
  List<Object?> get props => [invitationCode];
}

class LeaveKitchen extends KitchenEvent {
  final String kitchenId;

  const LeaveKitchen(this.kitchenId);

  @override
  List<Object?> get props => [kitchenId];
}

class CreateKitchenEvent extends KitchenEvent {
  final String kitchenName;
  CreateKitchenEvent(this.kitchenName);
}

class JoinKitchenEvent extends KitchenEvent {
  final String invitationCode;
  JoinKitchenEvent(this.invitationCode);
}

class SwitchKitchenEvent extends KitchenEvent {
  final String kitchenId;
  SwitchKitchenEvent(this.kitchenId);
}
