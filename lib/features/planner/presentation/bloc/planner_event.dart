sealed class PlannerEvent {}

final class GenerateRecipesEvent extends PlannerEvent {
  final String instructions;
  final String kitchenId;

  GenerateRecipesEvent({required this.instructions, required this.kitchenId});
}
