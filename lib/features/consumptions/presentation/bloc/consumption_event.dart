sealed class ConsumptionEvent {}

final class RespondConsumptionConfirmationPendingEvent
    extends ConsumptionEvent {
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

final class GetConsumptionConfirmationPendingEvent extends ConsumptionEvent {
  final String kitchenId;

  GetConsumptionConfirmationPendingEvent({required this.kitchenId});
}

final class GetConsumptionConfirmationPendingCountEvent
    extends ConsumptionEvent {
  final String kitchenId;

  GetConsumptionConfirmationPendingCountEvent({required this.kitchenId});
}
