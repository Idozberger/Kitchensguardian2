import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUserStorageArea
    implements UseCase<List<PantriesCommonEntity>, GetUserStorageAreaParams> {
  final HomeRepository kitchenRepository;
  const GetUserStorageArea(this.kitchenRepository);

  @override
  Future<Either<Failure, List<PantriesCommonEntity>>> call(
    GetUserStorageAreaParams params,
  ) async {
    return await kitchenRepository.getAllPantries(kitchenId: params.kitchenId);
  }
}

class GetUserStorageAreaParams {
  final String kitchenId;

  GetUserStorageAreaParams({required this.kitchenId});
}
