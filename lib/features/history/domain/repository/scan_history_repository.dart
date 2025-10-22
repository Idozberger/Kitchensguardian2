import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/history/domain/entities/scan_history_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ScanHistoryRepository {
  Future<Either<Failure, List<ScanHistoryEntity>>> getScanHistory({
    required String pageNumber,
  });
}
