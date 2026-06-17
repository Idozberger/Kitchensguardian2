import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/domain/entities/kitchen_date_range_entity.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetDateRange
    implements UseCase<KitchenDateRangeEntity, GetDateRangeParams> {
  final PlannerRepository plannerRepository;
  const GetDateRange(this.plannerRepository);

  @override
  Future<Either<Failure, KitchenDateRangeEntity>> call(
    GetDateRangeParams params,
  ) async {
    return await plannerRepository.getDateRange(kitchenId: params.kitchenId);
  }
}

class GetDateRangeParams {
  final String kitchenId;
  GetDateRangeParams(this.kitchenId);
}
