import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/grocery/domain/entities/requested_item.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class GroceryRepository {
  Future<Either<Failure, List<RequestedItemEntity>>> getRequestedItems({
    required String kitchenId,
  });
}
