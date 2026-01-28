import 'package:foodkitchen/features/consumptions/domain/entities/consumption_confirmation.dart';

final class ConsumptionState {
  final List<ConsumptionConfirmation> comsumptionConfirmationPending;
  final String comsumptionConfirmationPendingCount;

  final bool isLoading;
  final bool respondingOnConsumptionLoader;
  final String? errorMessage;
  final String? successMessage;

  const ConsumptionState({
    this.comsumptionConfirmationPending = const [],
    this.comsumptionConfirmationPendingCount = "",
    this.isLoading = false,
    this.respondingOnConsumptionLoader = false,
    this.errorMessage,
    this.successMessage,
  });

  ConsumptionState copyWith({
    List<ConsumptionConfirmation>? comsumptionConfirmationPending,
    String? comsumptionConfirmationPendingCount,
    bool? isLoading,
    bool? respondingOnConsumptionLoader,
    String? errorMessage,
    String? successMessage,
  }) {
    return ConsumptionState(
      comsumptionConfirmationPending:
          comsumptionConfirmationPending ?? this.comsumptionConfirmationPending,
      comsumptionConfirmationPendingCount:
          comsumptionConfirmationPendingCount ??
          this.comsumptionConfirmationPendingCount,
      isLoading: isLoading ?? this.isLoading,
      respondingOnConsumptionLoader:
          respondingOnConsumptionLoader ?? this.respondingOnConsumptionLoader,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
