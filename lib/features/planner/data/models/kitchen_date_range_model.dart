import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/planner/domain/entities/kitchen_date_range_entity.dart';

class KitchenDateRangeModel extends KitchenDateRangeEntity {
  const KitchenDateRangeModel({
    required super.kitchenId,
    required super.kitchenName,
    required super.startDate,
    required super.endDate,
    required super.dateRangeUpdatedAt,
  });

  factory KitchenDateRangeModel.fromJson(Map<String, dynamic> json) {
    return KitchenDateRangeModel(
      kitchenId: readJsonString(json, 'kitchen_id'),
      kitchenName: readJsonString(json, 'kitchen_name'),
      startDate: readJsonString(json, 'start_date'),
      endDate: readJsonString(json, 'end_date'),
      dateRangeUpdatedAt: readJsonString(json, 'date_range_updated_at'),
    );
  }
}
