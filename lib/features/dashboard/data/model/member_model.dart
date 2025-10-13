import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';

class MemberModel extends Member {
  MemberModel({
    required super.name,
    required super.type,
    required super.userId,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'type': type, 'user_id': userId};
  }
}
