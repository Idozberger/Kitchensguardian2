import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class FavouriteRecipes
    implements UseCase<List<RecipeEntity>, FavouriteRecipeParams> {
  final PlannerRepository plannerRepository;
  const FavouriteRecipes(this.plannerRepository);

  @override
  Future<Either<Failure, List<RecipeEntity>>> call(
    FavouriteRecipeParams params,
  ) async {
    return await plannerRepository.favouriteRecipes(
      kitchenId: params.kitchenId,
    );
  }
}

class FavouriteRecipeParams {
  final String kitchenId;
  FavouriteRecipeParams(this.kitchenId);
}
