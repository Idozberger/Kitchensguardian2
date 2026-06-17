import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/history/domain/entities/scan_history_entity.dart';
import 'package:foodkitchen/features/history/domain/repository/scan_history_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetScanHistoryUsecase
    implements UseCase<List<ScanHistoryEntity>, GetScanHistoryUsecaseParams> {
  final ScanHistoryRepository scanHistoryRepository;
  const GetScanHistoryUsecase(this.scanHistoryRepository);

  @override
  Future<Either<Failure, List<ScanHistoryEntity>>> call(
    GetScanHistoryUsecaseParams params,
  ) async {
    return await scanHistoryRepository.getScanHistory(
      pageNumber: params.pageNumber,
    );
  }
}

class GetScanHistoryUsecaseParams {
  final String pageNumber;

  GetScanHistoryUsecaseParams({required this.pageNumber});
}
