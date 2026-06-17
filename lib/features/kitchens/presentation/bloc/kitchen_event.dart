import 'package:equatable/equatable.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';

abstract class KitchenEvent extends Equatable {
  const KitchenEvent();

  @override
  List<Object?> get props => [];
}

class FetchKitchens extends KitchenEvent {}

class LeaveKitchenEvent extends KitchenEvent {
  final String kitchenId;

  const LeaveKitchenEvent(this.kitchenId);

  @override
  List<Object?> get props => [kitchenId];
}

class RemoveKitchenEvent extends KitchenEvent {
  final String kitchenId;

  const RemoveKitchenEvent(this.kitchenId);

  @override
  List<Object?> get props => [kitchenId];
}

class CreateKitchenEvent extends KitchenEvent {
  final String kitchenName;
  const CreateKitchenEvent(this.kitchenName);
}

class JoinKitchenEvent extends KitchenEvent {
  final String invitationCode;
  const JoinKitchenEvent(this.invitationCode);
}

class MemberApprovedEvent extends KitchenEvent {
  final String invitationCode;
  final String userId;
  const MemberApprovedEvent(this.invitationCode, this.userId);
}

class SwitchKitchenEvent extends KitchenEvent {
  final Kitchen kitchen;
  const SwitchKitchenEvent(this.kitchen);
}

class DeleteOrLeaveKitchenEvent extends KitchenEvent {}

class FetchAllUsers extends KitchenEvent {}

class InviteUserEvent extends KitchenEvent {
  final String kitchenId;
  final String email;
  final int index;
  const InviteUserEvent({
    required this.kitchenId,
    required this.email,
    required this.index,
  });
}
