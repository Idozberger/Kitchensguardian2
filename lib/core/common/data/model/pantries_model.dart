import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';

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
      pantryId: json["pantry_id"] ?? "",
      pantryName: json["pantry_name"] ?? "",
      createdAt: json["created_at"] ?? "",
    );
  }
}
