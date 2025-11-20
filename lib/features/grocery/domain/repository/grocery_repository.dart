import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class GroceryRepository {
  Future<Either<Failure, List<RequestedItemEntity>>> getRequestedItems({
    required String kitchenId,
  });
  Future<Either<Failure, List<RequestedItemEntity>>> updateBucketType({
    required String kitchenId,
    required List<String> itemsIds,
    required String bucketType,
  });
  Future<Either<Failure, List<RequestedItemEntity>>>
  addMyListToKitchenInventory({required String kitchenId});

  Future<Either<Failure, List<RequestedItemEntity>>> getAiGeneratedItems({
    required String kitchenId,
  });

  Future<Either<Failure, List<RequestedItemEntity>>> deleteKitchenItems({
    required String kitchenId,
    required List<String> itemsIds,
  });

  Future<Either<Failure, List<RequestedItemEntity>>> addCustomItems({
    required String kitchenId,
    required String name,
    required String quantity,
    required String unit,
    required String bucketType,
  });
}
