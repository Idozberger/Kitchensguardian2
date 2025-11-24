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
      kitchenId: json["kitchen_id"] ?? "",
      kitchenName: json["kitchen_name"] ?? "",
      startDate: json["start_date"] ?? "",
      endDate: json["end_date"] ?? "",
      dateRangeUpdatedAt: json["date_range_updated_at"] ?? "",
    );
  }
}
