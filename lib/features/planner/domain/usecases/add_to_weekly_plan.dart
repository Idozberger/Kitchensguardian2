import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddToWeeklyPlan implements UseCase<String, AddToWeeklyPlanParams> {
  final PlannerRepository plannerRepository;
  const AddToWeeklyPlan(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(AddToWeeklyPlanParams params) async {
    return await plannerRepository.addToWeeklyPlan(
      RecipeEntity: params.recipeEntity,
    );
  }
}

class AddToWeeklyPlanParams {
  final RecipeEntity recipeEntity;
  AddToWeeklyPlanParams(this.recipeEntity);
}
