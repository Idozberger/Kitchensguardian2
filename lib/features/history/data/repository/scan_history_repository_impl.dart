import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/features/history/data/datasource/scan_history_remote_datasource.dart';
import 'package:foodkitchen/features/history/data/models/scan_history_model.dart';
import 'package:foodkitchen/features/history/domain/entities/scan_history_entity.dart';
import 'package:foodkitchen/features/history/domain/repository/scan_history_repository.dart';
import 'package:fpdart/fpdart.dart';

class ScanHistoryRepositoryImpl implements ScanHistoryRepository {
  final ScanHistoryRemoteDatasource scanHistoryRemoteDatasource;
  ScanHistoryRepositoryImpl(this.scanHistoryRemoteDatasource);
  @override
  Future<Either<Failure, List<ScanHistoryEntity>>> getScanHistory({
    required String pageNumber,
  }) async {
    try {
      final response = await scanHistoryRemoteDatasource.getScanHistory(
        pageNumber: pageNumber,
      );

      final scanHistoryItems = (response as List)
          .map((e) => ScanHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      logError(scanHistoryItems);
      return Right(scanHistoryItems);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
