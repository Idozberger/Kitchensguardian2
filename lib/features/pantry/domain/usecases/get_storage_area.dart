import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUserStorageAreaForPantryView
    implements
        UseCase<
          List<PantriesCommonEntity>,
          GetUserStorageAreaForPantryViewParams
        > {
  final PantryRepository kitchenRepository;
  const GetUserStorageAreaForPantryView(this.kitchenRepository);

  @override
  Future<Either<Failure, List<PantriesCommonEntity>>> call(
    GetUserStorageAreaForPantryViewParams params,
  ) async {
    return await kitchenRepository.getAllStorageArea(
      kitchenId: params.kitchenId,
    );
  }
}

class GetUserStorageAreaForPantryViewParams {
  final String kitchenId;

  GetUserStorageAreaForPantryViewParams({required this.kitchenId});
}
