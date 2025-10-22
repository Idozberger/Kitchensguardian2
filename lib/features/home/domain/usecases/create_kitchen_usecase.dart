import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/home/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateKitchen implements UseCase<Kitchen, CreateKitchenParams> {
  final HomeRepository kitchenRepository;
  const CreateKitchen(this.kitchenRepository);

  @override
  Future<Either<Failure, Kitchen>> call(CreateKitchenParams params) async {
    return await kitchenRepository.createKitchen(
      kitchenName: params.kitchenName,
    );
  }
}

class CreateKitchenParams {
  final String kitchenName;

  CreateKitchenParams({required this.kitchenName});
}
