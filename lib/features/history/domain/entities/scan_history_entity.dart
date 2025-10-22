import 'package:foodkitchen/features/history/domain/entities/scan_item_entity.dart';

class ScanHistoryEntity {
  final List<ScanItemEntity> items;
  final DateTime scannedAt;
  final String userId;

  const ScanHistoryEntity({
    required this.items,
    required this.scannedAt,
    required this.userId,
  });
}
