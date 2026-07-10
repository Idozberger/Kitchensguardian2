import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Reads the active kitchen's `unit_system` from the backend
/// (`GET /api/kitchen/get_unit_system`). Used as the explicit refresh path
/// for KG-8; the primary source is the kitchen list/view responses.
class GetUnitSystem implements UseCase<String, GetUnitSystemParams> {
  final KitchenRepository kitchenRepository;
  const GetUnitSystem(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(GetUnitSystemParams params) async {
    return await kitchenRepository.getUnitSystem(kitchenId: params.kitchenId);
  }
}

class GetUnitSystemParams {
  final String kitchenId;
  const GetUnitSystemParams({required this.kitchenId});
}
