import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class ScanReceiptUseCase
    implements UseCase<ScanReceipt, ScanReceiptUseCaseParams> {
  final PantryRepository pantryRepository;
  const ScanReceiptUseCase(this.pantryRepository);

  @override
  Future<Either<Failure, ScanReceipt>> call(
    ScanReceiptUseCaseParams params,
  ) async {
    return await pantryRepository.scanRecipt(filePath: params.filePath);
  }
}

class ScanReceiptUseCaseParams {
  final String filePath;

  ScanReceiptUseCaseParams({required this.filePath});
}
