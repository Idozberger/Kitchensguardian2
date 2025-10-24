import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

class LeaveKitchenUsecase implements UseCase<String, LeaveKitchenParams> {
  final KitchenRepository kitchenRepository;
  const LeaveKitchenUsecase(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(LeaveKitchenParams params) async {
    return await kitchenRepository.leaveKitchen(kitchenId: params.kitchenId);
  }
}

class LeaveKitchenParams {
  final String kitchenId;

  LeaveKitchenParams({required this.kitchenId});
}
