import 'package:foodkitchen/features/consumptions/domain/entities/consumption_confirmation.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  final List<Member> kitchenMembers;
  final List<ConsumptionConfirmation> comsumptionConfirmationPending;
  final String comsumptionConfirmationPendingCount;
  final bool respondingOnConsumptionLoader;

  DashboardLoaded({
    this.comsumptionConfirmationPending = const [],
    this.kitchenMembers = const [],
    this.comsumptionConfirmationPendingCount = "",
    this.respondingOnConsumptionLoader = false,
  });

  DashboardLoaded copyWith({
    List<Member>? kitchenMembers,
    List<ConsumptionConfirmation>? comsumptionConfirmationPending,
    String? comsumptionConfirmationPendingCount,
    bool? respondingOnConsumptionLoader,
  }) {
    return DashboardLoaded(
      kitchenMembers: kitchenMembers ?? this.kitchenMembers,
      comsumptionConfirmationPending:
          comsumptionConfirmationPending ?? this.comsumptionConfirmationPending,
      comsumptionConfirmationPendingCount:
          comsumptionConfirmationPendingCount ??
          this.comsumptionConfirmationPendingCount,
      respondingOnConsumptionLoader:
          respondingOnConsumptionLoader ?? this.respondingOnConsumptionLoader,
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

class ApproveLoading extends DashboardState {
  final String id;
  const ApproveLoading(this.id);
}

class DeclineLoading extends DashboardState {
  final String id;
  const DeclineLoading(this.id);
}
