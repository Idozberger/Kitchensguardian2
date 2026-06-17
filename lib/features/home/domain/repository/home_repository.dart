import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';

import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/home/domain/entities/item_request.dart';
import 'package:foodkitchen/features/home/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, Kitchen>> createKitchen({required String kitchenName});
  Future<Either<Failure, String>> respondToItemRequest({
    required String action,
    required String rejectReason,
    required String requestId,
  });
  Future<Either<Failure, PantriesDataEntity>> getItems({
    required String kitchenId,
  });
  Future<Either<Failure, List<RecipeEntity>>> getAllWeeklyPlans({
    required String kicthenId,
  });
  Future<Either<Failure, RecipeEntity>> getRecipeSuggestion({
    required String kicthenId,
  });
  Future<Either<Failure, List<ItemRequest>>> getAllRequestedItems({
    required String kitchenId,
  });
}
