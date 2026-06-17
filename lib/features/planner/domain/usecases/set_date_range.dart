import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/domain/entities/kitchen_date_range_entity.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class SetDateRange
    implements UseCase<KitchenDateRangeEntity, SetDateRangeParams> {
  final PlannerRepository plannerRepository;
  const SetDateRange(this.plannerRepository);

  @override
  Future<Either<Failure, KitchenDateRangeEntity>> call(
    SetDateRangeParams params,
  ) async {
    return await plannerRepository.setDateRange(
      kitchenId: params.kitchenId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class SetDateRangeParams {
  final String kitchenId;
  final String startDate;
  final String endDate;
  SetDateRangeParams({
    required this.endDate,
    required this.kitchenId,
    required this.startDate,
  });
}
