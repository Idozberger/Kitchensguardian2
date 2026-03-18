import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/repository/smart_kitchen_setup_repository.dart';
import 'package:fpdart/fpdart.dart';

class SkipKitchenSetup implements UseCase<String, SkipKitchenSetupParams> {
  final SmartKitchenSetupRepository smartKitchenSetupRepository;

  const SkipKitchenSetup(this.smartKitchenSetupRepository);

  @override
  Future<Either<Failure, String>> call(SkipKitchenSetupParams params) async {
    return await smartKitchenSetupRepository.skipKitchenSetup(
      kitchenId: params.kitchenId,
    );
  }
}

class SkipKitchenSetupParams {
  final String kitchenId;

  SkipKitchenSetupParams({required this.kitchenId});
}
