import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_type_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PlannerRepository {
  Future<Either<Failure, List<MealTypeEntity>>> generateRecipes({
    required String instructions,
    required String kitchenId,
  });
}
