import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetKitchens implements UseCase<List<Kitchen>, NoParams> {
  final KitchenRepository kitchenRepository;
  const GetKitchens(this.kitchenRepository);

  @override
  Future<Either<Failure, List<Kitchen>>> call(NoParams params) async {
    return await kitchenRepository.getKitchens();
  }
}

class NoParams {}
