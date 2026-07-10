import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';

class KitchenModel extends Kitchen {
  KitchenModel({
    required super.invitationCode,
    required super.kitchenId,
    required super.kitchenName,
    required super.role,
    super.unitSystem,
  });
  factory KitchenModel.fromJson(Map<String, dynamic> map) {
    return KitchenModel(
      invitationCode: readJsonString(map, 'invitation_code'),
      kitchenId: readJsonString(map, 'kitchen_id'),
      kitchenName: readJsonString(map, 'kitchen_name'),
      role: readJsonString(map, 'role'),
      unitSystem: readJsonString(map, 'unit_system', fallback: 'metric'),
    );
  }
}
