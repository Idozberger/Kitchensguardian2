import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateKitchenUseCase implements UseCase<String, CreateKitchenParams> {
  final KitchenRepository kitchenRepository;
  const CreateKitchenUseCase(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(CreateKitchenParams params) async {
    return await kitchenRepository.createKitchen(
      kitchenName: params.kitchenName,
      unitSystem: params.unitSystem,
    );
  }
}

class CreateKitchenParams {
  final String kitchenName;

  /// Measurement system chosen at kitchen creation (BRD UC-03).
  final UnitSystem unitSystem;

  CreateKitchenParams({
    required this.kitchenName,
    this.unitSystem = UnitSystem.metric,
  });
}
