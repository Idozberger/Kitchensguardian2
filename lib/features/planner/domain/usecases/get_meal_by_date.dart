import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetMealByDate implements UseCase<String, GetMealByDateParams> {
  final PlannerRepository plannerRepository;
  const GetMealByDate(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(GetMealByDateParams params) async {
    return await plannerRepository.getMealByDate(
      kitchenId: params.kitchenId,
      date: params.date,
    );
  }
}

class GetMealByDateParams {
  final String date;
  final String kitchenId;
  GetMealByDateParams({required this.date, required this.kitchenId});
}
