import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_plan_entity.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreatePlan implements UseCase<String, CreatePlanParams> {
  final PlannerRepository plannerRepository;
  const CreatePlan(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(CreatePlanParams params) async {
    return await plannerRepository.createMealPlan(mealPlans: params.mealPlans);
  }
}

class CreatePlanParams {
  final List<MealPlanEntity> mealPlans;
  CreatePlanParams(this.mealPlans);
}
