import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetRecipeDetails
    implements UseCase<RecipeEntity, GetRecipeDetailsParams> {
  final DashboardRepository dashboardRepository;
  const GetRecipeDetails(this.dashboardRepository);

  @override
  Future<Either<Failure, RecipeEntity>> call(
    GetRecipeDetailsParams params,
  ) async {
    return await dashboardRepository.getRecipeDetails(
      kitchenId: params.kitchenId,
      recipeId: params.recipeId,
    );
  }
}

class GetRecipeDetailsParams {
  final String recipeId;
  final String kitchenId;

  GetRecipeDetailsParams({required this.recipeId, required this.kitchenId});
}
