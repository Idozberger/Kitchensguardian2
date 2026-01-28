import 'package:foodkitchen/features/history/data/models/scan_item_model.dart';
import 'package:foodkitchen/features/history/domain/entities/scan_history_entity.dart';

class ScanHistoryModel extends ScanHistoryEntity {
  ScanHistoryModel({
    required super.items,
    required super.scannedAt,
    required super.userId,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      items: (json['items'] as List? ?? [])
          .map((item) => ScanItemModel.fromJson(item))
          .toList(),
      scannedAt: DateTime.parse(json['scanned_at']),
      userId: json['user_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => (e as ScanItemModel).toJson()).toList(),
    'scanned_at': scannedAt.toUtc().toIso8601String(),
    'user_id': userId,
  };
}
