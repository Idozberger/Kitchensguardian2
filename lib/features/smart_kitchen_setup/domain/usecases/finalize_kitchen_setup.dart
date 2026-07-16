import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/repository/smart_kitchen_setup_repository.dart';
import 'package:fpdart/fpdart.dart';

class FinalizeKitchenSetup
    implements UseCase<String, FinalizeKitchenSetupParams> {
  final SmartKitchenSetupRepository smartKitchenSetupRepository;

  const FinalizeKitchenSetup(this.smartKitchenSetupRepository);

  @override
  Future<Either<Failure, String>> call(FinalizeKitchenSetupParams params) {
    return smartKitchenSetupRepository.finalizeSetup(
      sessionId: params.sessionId,
      items: params.items,
    );
  }
}

class FinalizeKitchenSetupParams {
  final String sessionId;
  final List<Map<String, dynamic>> items;

  const FinalizeKitchenSetupParams({
    required this.sessionId,
    required this.items,
  });
}
