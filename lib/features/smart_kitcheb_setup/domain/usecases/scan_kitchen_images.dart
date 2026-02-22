import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/domain/entities/scanned_item.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/domain/repository/smart_kitchen_setup_repository.dart';
import 'package:fpdart/fpdart.dart';

class ScanKitchenImagesUseCase
    implements
        UseCase<List<ScannedItemEntity>, ScanKitchenImagesUseCaseParams> {
  final SmartKitchenSetupRepository smartKitchenSetupRepository;

  const ScanKitchenImagesUseCase(this.smartKitchenSetupRepository);

  @override
  Future<Either<Failure, List<ScannedItemEntity>>> call(
    ScanKitchenImagesUseCaseParams params,
  ) async {
    try {
      final result = await smartKitchenSetupRepository.scanKitchenImages(
        kitchenId: params.kitchenId,
        fridgeFilePath: params.fridgeFilePath,
        freezerFilePath: params.freezerFilePath,
        pantryFilePath: params.pantryFilePath,
        spicesFilePath: params.spicesFilePath,
        miscFilePath: params.miscFilePath,
      );
      return Right(result);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}

class ScanKitchenImagesUseCaseParams {
  final String kitchenId;
  final String fridgeFilePath;
  final String freezerFilePath;
  final String pantryFilePath;
  final String spicesFilePath;
  final String miscFilePath;

  ScanKitchenImagesUseCaseParams({
    required this.kitchenId,
    required this.fridgeFilePath,
    required this.freezerFilePath,
    required this.pantryFilePath,
    required this.spicesFilePath,
    required this.miscFilePath,
  });
}
