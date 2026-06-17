import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/grocery/domain/repository/grocery_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteKitchenItems
    implements UseCase<List<RequestedItemEntity>, DeleteKitchenItemsParams> {
  final GroceryRepository groceryRepository;
  const DeleteKitchenItems(this.groceryRepository);

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> call(
    DeleteKitchenItemsParams params,
  ) async {
    return await groceryRepository.deleteKitchenItems(
      kitchenId: params.kitchenId,
      itemsIds: params.itemIds,
    );
  }
}

class DeleteKitchenItemsParams {
  final String kitchenId;
  final List<String> itemIds;

  DeleteKitchenItemsParams({required this.itemIds, required this.kitchenId});
}
