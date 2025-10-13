import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  final List<Member> kitchenMembers;
  DashboardLoaded(this.kitchenMembers);
}

final class DashboardSuccess extends DashboardState {
  final String successMessage;
  DashboardSuccess(this.successMessage);
}

final class DashboardFailure extends DashboardState {
  final String message;
  const DashboardFailure(this.message);
}
