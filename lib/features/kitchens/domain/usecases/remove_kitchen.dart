import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveKitchenUsecase implements UseCase<String, RemoveKitchenParams> {
  final KitchenRepository kitchenRepository;
  const RemoveKitchenUsecase(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(RemoveKitchenParams params) async {
    return await kitchenRepository.removeKitchen(kitchenId: params.kitchenId);
  }
}

class RemoveKitchenParams {
  final String kitchenId;

  RemoveKitchenParams({required this.kitchenId});
}
