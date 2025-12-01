import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllWeeklyPlansForHome
    implements UseCase<List<RecipeEntity>, GetAllWeeklyPlansForHomeParams> {
  final HomeRepository homeRepository;
  const GetAllWeeklyPlansForHome(this.homeRepository);

  @override
  Future<Either<Failure, List<RecipeEntity>>> call(
    GetAllWeeklyPlansForHomeParams params,
  ) async {
    return await homeRepository.getAllWeeklyPlans(kicthenId: params.kitchenId);
  }
}

class GetAllWeeklyPlansForHomeParams {
  final String kitchenId;
  GetAllWeeklyPlansForHomeParams(this.kitchenId);
}
