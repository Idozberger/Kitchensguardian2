import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllPlans implements UseCase<List<MealTypeEntity>, GetAllPlansParams> {
  final PlannerRepository plannerRepository;
  const GetAllPlans(this.plannerRepository);

  @override
  Future<Either<Failure, List<MealTypeEntity>>> call(
    GetAllPlansParams params,
  ) async {
    return await plannerRepository.listAllMealPlans(
      kitchenId: params.kitchenId,
    );
  }
}

class GetAllPlansParams {
  final String kitchenId;

  GetAllPlansParams({required this.kitchenId});
}
