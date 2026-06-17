import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetPantriesForHome
    implements UseCase<PantriesDataEntity, GetPantriesForHomeParams> {
  final HomeRepository homeRepository;
  const GetPantriesForHome(this.homeRepository);

  @override
  Future<Either<Failure, PantriesDataEntity>> call(
    GetPantriesForHomeParams params,
  ) async {
    return await homeRepository.getItems(kitchenId: params.kitchenId);
  }
}

class GetPantriesForHomeParams {
  final String kitchenId;

  GetPantriesForHomeParams({required this.kitchenId});
}
