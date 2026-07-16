import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/kitchen_setup_scan_result.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/repository/smart_kitchen_setup_repository.dart';
import 'package:fpdart/fpdart.dart';

class ScanKitchenImagesUseCase
    implements UseCase<KitchenSetupScanResult, ScanKitchenImagesUseCaseParams> {
  final SmartKitchenSetupRepository smartKitchenSetupRepository;

  const ScanKitchenImagesUseCase(this.smartKitchenSetupRepository);

  @override
  Future<Either<Failure, KitchenSetupScanResult>> call(
    ScanKitchenImagesUseCaseParams params,
  ) {
    return smartKitchenSetupRepository.scanKitchenImages(
      kitchenId: params.kitchenId,
      fridgeFilePaths: params.fridgeFilePaths,
      freezerFilePaths: params.freezerFilePaths,
      pantryFilePaths: params.pantryFilePaths,
      spicesFilePaths: params.spicesFilePaths,
      miscFilePaths: params.miscFilePaths,
    );
  }
}

class ScanKitchenImagesUseCaseParams {
  final String kitchenId;
  final List<String> fridgeFilePaths;
  final List<String> freezerFilePaths;
  final List<String> pantryFilePaths;
  final List<String> spicesFilePaths;
  final List<String> miscFilePaths;

  ScanKitchenImagesUseCaseParams({
    required this.kitchenId,
    required this.fridgeFilePaths,
    required this.freezerFilePaths,
    required this.pantryFilePaths,
    required this.spicesFilePaths,
    required this.miscFilePaths,
  });
}
