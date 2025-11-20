import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/features/grocery/domain/repository/grocery_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateBucketType
    implements UseCase<List<RequestedItemEntity>, UpdateBucketTypeParams> {
  final GroceryRepository groceryRepository;
  const UpdateBucketType(this.groceryRepository);

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> call(
    UpdateBucketTypeParams params,
  ) async {
    return await groceryRepository.updateBucketType(
      kitchenId: params.kitchenId,
      itemsIds: params.itemIds,
      bucketType: params.bucketType,
    );
  }
}

class UpdateBucketTypeParams {
  final String kitchenId;
  final List<String> itemIds;
  final String bucketType;

  UpdateBucketTypeParams({
    required this.bucketType,
    required this.itemIds,
    required this.kitchenId,
  });
}
