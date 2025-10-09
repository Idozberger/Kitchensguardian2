import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';

class KitchenModel extends Kitchen {
  KitchenModel({
    required super.invitationCode,
    required super.kitchenId,
    required super.kitchenName,
    required super.role,
  });
  factory KitchenModel.fromJson(Map<String, dynamic> map) {
    return KitchenModel(
      invitationCode: map['invitation_code'] ?? '',
      kitchenId: map['kitchen_id'] ?? '',
      kitchenName: map['kitchen_name'] ?? '',
      role: map['role'] ?? '',
    );
  }
}
