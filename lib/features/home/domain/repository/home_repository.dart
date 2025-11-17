import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';

import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/home/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, Kitchen>> createKitchen({required String kitchenName});
  Future<Either<Failure, String>> joinKitchen({required String invitationCode});
  Future<Either<Failure, PantriesDataEntity>> getItems({
    required String kitchenId,
  });
  Future<Either<Failure, List<MealTypeEntity>>> getAllWeeklyPlans();
}
