import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllWeeklyPlansForHome
    implements UseCase<List<MealTypeEntity>, NoParams> {
  final HomeRepository homeRepository;
  const GetAllWeeklyPlansForHome(this.homeRepository);

  @override
  Future<Either<Failure, List<MealTypeEntity>>> call(NoParams params) async {
    return await homeRepository.getAllWeeklyPlans();
  }
}
