import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/history/data/models/scan_item_model.dart';
import 'package:foodkitchen/features/history/domain/entities/scan_history_entity.dart';

class ScanHistoryModel extends ScanHistoryEntity {
  ScanHistoryModel({
    required super.items,
    required super.scannedAt,
    required super.userId,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    final Object? itemsRaw = json['items'];
    final List<dynamic> itemsList = itemsRaw is List<dynamic> ? itemsRaw : [];
    return ScanHistoryModel(
      items: itemsList
          .map(
            (Object? item) =>
                ScanItemModel.fromJson(jsonObjectFromResponseData(item)),
          )
          .toList(),
      scannedAt:
          DateTime.tryParse(readJsonString(json, 'scanned_at')) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      userId: readJsonString(json, 'user_id'),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => (e as ScanItemModel).toJson()).toList(),
    'scanned_at': scannedAt.toUtc().toIso8601String(),
    'user_id': userId,
  };
}
