import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class FavouriteRecipes implements UseCase<List<MealTypeEntity>, NoParams> {
  final PlannerRepository plannerRepository;
  const FavouriteRecipes(this.plannerRepository);

  @override
  Future<Either<Failure, List<MealTypeEntity>>> call(NoParams params) async {
    return await plannerRepository.favouriteRecipes();
  }
}
