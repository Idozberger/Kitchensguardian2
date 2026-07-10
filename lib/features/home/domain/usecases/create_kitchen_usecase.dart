import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
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
