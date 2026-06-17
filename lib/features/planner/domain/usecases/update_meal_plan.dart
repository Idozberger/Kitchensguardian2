import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateMealPlan implements UseCase<String, UpdateMealPlanParams> {
  final PlannerRepository plannerRepository;
  const UpdateMealPlan(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(UpdateMealPlanParams params) async {
    return await plannerRepository.updateMealPlan(
      mealPlanId: params.mealPlanId,
      mealType: params.mealType,
      notes: params.notes,
      recipeId: params.recipeId,
    );
  }
}

class UpdateMealPlanParams {
  final String mealPlanId;
  final String mealType;
  final String notes;
  final String recipeId;
  UpdateMealPlanParams({
    required this.mealPlanId,
    required this.mealType,
    required this.notes,
    required this.recipeId,
  });
}
