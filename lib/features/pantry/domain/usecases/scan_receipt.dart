import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class ScanReceiptUseCase
    implements UseCase<ScanReceiptEntity, ScanReceiptUseCaseParams> {
  final PantryRepository pantryRepository;
  const ScanReceiptUseCase(this.pantryRepository);

  @override
  Future<Either<Failure, ScanReceiptEntity>> call(
    ScanReceiptUseCaseParams params,
  ) async {
    return await pantryRepository.scanRecipt(
      filePath: params.filePath,
      currency: params.currency,
      country: params.country,
      kitchenId: params.kitchenId,
    );
  }
}

class ScanReceiptUseCaseParams {
  final String filePath;
  final String currency;
  final String country;
  final String kitchenId;

  ScanReceiptUseCaseParams({
    required this.filePath,
    required this.currency,
    required this.country,
    required this.kitchenId,
  });
}
