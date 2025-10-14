import 'package:foodkitchen/features/planner/domain/entities/meal_type_entity.dart';

sealed class PlannerState {
  const PlannerState();
}

final class PlannerInitial extends PlannerState {}

final class PlannerLoading extends PlannerState {}

final class PlannerSuccess extends PlannerState {
  final String successMessage;
  PlannerSuccess(this.successMessage);
}

final class PlannerFailure extends PlannerState {
  final String message;
  const PlannerFailure(this.message);
}

final class PlannerRecipesLoaded extends PlannerState {
  final List<MealTypeEntity> recipes;
  const PlannerRecipesLoaded(this.recipes);
}
