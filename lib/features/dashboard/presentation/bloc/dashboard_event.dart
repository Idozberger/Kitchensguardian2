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
