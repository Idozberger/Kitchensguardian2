sealed class DashboardEvent {}

final class GetKitchenMembersEvent extends DashboardEvent {
  final String activeKitchenId;
  GetKitchenMembersEvent({required this.activeKitchenId});
}

final class MakeCohostEvent extends DashboardEvent {
  final String activeKitchenId;
  final String memberId;
  MakeCohostEvent({required this.activeKitchenId, required this.memberId});
}

final class KickMemberEvent extends DashboardEvent {
  final String activeKitchenId;
  final String memberId;
  KickMemberEvent({required this.activeKitchenId, required this.memberId});
}

final class ApproveRequestEvent extends DashboardEvent {
  final String kitchenId;
  final String memberId;
  final int id;

  ApproveRequestEvent({
    required this.memberId,
    required this.id,
    required this.kitchenId,
  });
}

final class DeclineRequestEvent extends DashboardEvent {
  final String kitchenId;
  final String memberId;
  final int id;

  DeclineRequestEvent({
    required this.memberId,
    required this.id,
    required this.kitchenId,
  });
}

final class RespondConsumptionConfirmationPendingEvent extends DashboardEvent {
  final String confirmationId;
  final String responseText;
  final String actualQuantityRemaining;
  final String kitchenId;

  RespondConsumptionConfirmationPendingEvent({
    required this.confirmationId,
    required this.actualQuantityRemaining,
    required this.responseText,
    required this.kitchenId,
  });
}

final class GetConsumptionConfirmationPendingEvent extends DashboardEvent {
  final String kitchenId;

  GetConsumptionConfirmationPendingEvent({required this.kitchenId});
}

final class GetConsumptionConfirmationPendingCountEvent extends DashboardEvent {
  final String kitchenId;

  GetConsumptionConfirmationPendingCountEvent({required this.kitchenId});
}
