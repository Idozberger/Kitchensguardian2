import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateKitchen implements UseCase<String, CreateKitchenParams> {
  final HomeRepository kitchenRepository;
  const CreateKitchen(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(CreateKitchenParams params) async {
    return await kitchenRepository.createKitchen(
      kitchenName: params.kitchenName,
    );
  }
}

class CreateKitchenParams {
  final String kitchenName;

  CreateKitchenParams({required this.kitchenName});
}
