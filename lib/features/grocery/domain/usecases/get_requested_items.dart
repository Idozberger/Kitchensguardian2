import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/grocery/domain/repository/grocery_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetRequestedItems
    implements UseCase<List<RequestedItemEntity>, GetRequestedItemsParams> {
  final GroceryRepository groceryRepository;
  const GetRequestedItems(this.groceryRepository);

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> call(
    GetRequestedItemsParams params,
  ) async {
    return await groceryRepository.getRequestedItems(
      kitchenId: params.kitchenId,
    );
  }
}

class GetRequestedItemsParams {
  final String kitchenId;

  GetRequestedItemsParams({required this.kitchenId});
}
