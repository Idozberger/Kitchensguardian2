import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteMealTypeFromWeeklyPlan
    implements UseCase<List<RecipeEntity>, DeleteMealTypeFromWeeklyPlanParams> {
  final PlannerRepository plannerRepository;
  const DeleteMealTypeFromWeeklyPlan(this.plannerRepository);

  @override
  Future<Either<Failure, List<RecipeEntity>>> call(
    DeleteMealTypeFromWeeklyPlanParams params,
  ) async {
    return await plannerRepository.deleteMealTypeFromWeeklyPlan(
      selectedDate: params.selectedDate,
      mealType: params.mealType,
    );
  }
}

class DeleteMealTypeFromWeeklyPlanParams {
  final String selectedDate;
  final String mealType;
  DeleteMealTypeFromWeeklyPlanParams({
    required this.selectedDate,
    required this.mealType,
  });
}
