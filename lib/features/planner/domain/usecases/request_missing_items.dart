import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class RequestMissingItems
    implements UseCase<String, RequestMissingItemsParams> {
  final PlannerRepository plannerRepository;
  const RequestMissingItems(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(RequestMissingItemsParams params) async {
    return await plannerRepository.requestItems(pantry: params.pantry);
  }
}

class RequestMissingItemsParams {
  final Pantry pantry;

  RequestMissingItemsParams({required this.pantry});
}
