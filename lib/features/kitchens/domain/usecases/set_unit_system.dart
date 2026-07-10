import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Persists the kitchen's measurement system
/// (`POST /api/kitchen/set_unit_system`). Backend gates this to the host.
/// Storage stays metric — the backend converts on read, so existing pantry,
/// recipe and grocery data surfaces in the new system automatically (BRD UC-04).
class SetUnitSystem implements UseCase<String, SetUnitSystemParams> {
  final KitchenRepository kitchenRepository;
  const SetUnitSystem(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(SetUnitSystemParams params) async {
    return await kitchenRepository.setUnitSystem(
      kitchenId: params.kitchenId,
      unitSystem: params.unitSystem,
    );
  }
}

class SetUnitSystemParams {
  final String kitchenId;
  final UnitSystem unitSystem;
  const SetUnitSystemParams({
    required this.kitchenId,
    required this.unitSystem,
  });
}
