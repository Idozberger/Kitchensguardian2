import 'package:foodkitchen/core/error/failures.dart';
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
      List<ScanHistoryModel> scanHistoryItems = [];
      for (var i = 0; i < response.length; i++) {
        scanHistoryItems.add(ScanHistoryModel.fromJson(response[i]));
      }

      return Right(scanHistoryItems);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
