import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

class PantriesCommonModel extends PantriesCommonEntity {
  PantriesCommonModel({
    required super.pantryId,
    required super.pantryName,
    required super.createdAt,
  });

  PantriesCommonModel copyWith({
    String? pantryId,
    String? pantryName,
    String? createdAt,
  }) {
    return PantriesCommonModel(
      pantryId: pantryId ?? this.pantryId,
      pantryName: pantryName ?? this.pantryName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "pantry_id": pantryId,
      "pantry_name": pantryName,
      "created_at": createdAt,
    };
  }

  factory PantriesCommonModel.fromJson(Map<String, dynamic> json) {
    return PantriesCommonModel(
      pantryId: readJsonString(json, 'pantry_id'),
      pantryName: readJsonString(json, 'pantry_name'),
      createdAt: readJsonString(json, 'created_at'),
    );
  }
}
