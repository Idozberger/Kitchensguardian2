import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/home/domain/entities/item_request.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllRequestedItems
    implements UseCase<List<ItemRequest>, GetAllRequestedItemsParams> {
  final HomeRepository homeRepository;
  const GetAllRequestedItems(this.homeRepository);

  @override
  Future<Either<Failure, List<ItemRequest>>> call(
    GetAllRequestedItemsParams params,
  ) async {
    return await homeRepository.getAllRequestedItems(
      kitchenId: params.kitchenId,
    );
  }
}

class GetAllRequestedItemsParams {
  final String kitchenId;

  GetAllRequestedItemsParams({required this.kitchenId});
}
