import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/features/grocery/domain/repository/grocery_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAiGeneratedItems
    implements UseCase<List<RequestedItemEntity>, GetAiGeneratedItemsParams> {
  final GroceryRepository groceryRepository;
  const GetAiGeneratedItems(this.groceryRepository);

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> call(
    GetAiGeneratedItemsParams params,
  ) async {
    return await groceryRepository.getAiGeneratedItems(
      kitchenId: params.kitchenId,
    );
  }
}

class GetAiGeneratedItemsParams {
  final String kitchenId;

  GetAiGeneratedItemsParams({required this.kitchenId});
}
