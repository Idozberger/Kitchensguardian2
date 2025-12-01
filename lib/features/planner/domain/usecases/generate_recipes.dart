import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class GenerateRecipes
    implements UseCase<List<RecipeEntity>, GenerateRecipesParams> {
  final PlannerRepository plannerRepository;
  const GenerateRecipes(this.plannerRepository);

  @override
  Future<Either<Failure, List<RecipeEntity>>> call(
    GenerateRecipesParams params,
  ) async {
    return await plannerRepository.generateRecipes(
      kitchenId: params.kitchenId,
      instructions: params.instructions,
    );
  }
}

class GenerateRecipesParams {
  final String instructions;
  final String kitchenId;

  GenerateRecipesParams({required this.instructions, required this.kitchenId});
}
