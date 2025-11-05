import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreatePantryUsecase
    implements UseCase<String, CreatePantryUsecaseParams> {
  final HomeRepository kitchenRepository;
  const CreatePantryUsecase(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(CreatePantryUsecaseParams params) async {
    return await kitchenRepository.createPantry(
      kitchenId: params.kitchenId,
      pantries: params.pantries,
    );
  }
}

class CreatePantryUsecaseParams {
  final String kitchenId;
  final List<String> pantries;

  CreatePantryUsecaseParams({required this.kitchenId, required this.pantries});
}
