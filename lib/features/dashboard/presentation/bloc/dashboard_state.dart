import 'package:foodkitchen/features/dashboard/domain/entities/consumption_confirmation.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  final List<Member> kitchenMembers;
  final List<ConsumptionConfirmation> comsumptionConfirmationPending;

  DashboardLoaded({
    this.comsumptionConfirmationPending = const [],
    this.kitchenMembers = const [],
  });

  DashboardLoaded copyWith({
    List<Member>? kitchenMembers,
    List<ConsumptionConfirmation>? comsumptionConfirmationPending,
  }) {
    return DashboardLoaded(
      kitchenMembers: kitchenMembers ?? this.kitchenMembers,
      comsumptionConfirmationPending:
          comsumptionConfirmationPending ?? this.comsumptionConfirmationPending,
    );
  }
}

final class DashboardSuccess extends DashboardState {
  final String successMessage;
  DashboardSuccess(this.successMessage);
}

final class DashboardFailure extends DashboardState {
  final String message;
  const DashboardFailure(this.message);
}

final class ApproveLoading extends DashboardState {}

final class DeclineLoading extends DashboardState {}
