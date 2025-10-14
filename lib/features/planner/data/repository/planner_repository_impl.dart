import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/data/datasource/planner_remote_datasource.dart';
import 'package:foodkitchen/features/planner/data/models/meal_type_model.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerRemoteDatasource plannerRemoteDatasource;
  PlannerRepositoryImpl(this.plannerRemoteDatasource);

  @override
  Future<Either<Failure, List<MealTypeEntity>>> generateRecipes({
    required String instructions,
    required String kitchenId,
  }) async {
    try {
      final response = await plannerRemoteDatasource.generateRecipes(
        instructions: instructions,
        kitchenId: kitchenId,
      );
      final generatedRecipes = (response as List)
          .map((e) => MealTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(generatedRecipes);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
