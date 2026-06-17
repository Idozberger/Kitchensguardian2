import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/users.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final String idFromUnderscore = readJsonString(json, '_id');
    return UserModel(
      id: idFromUnderscore.isNotEmpty
          ? idFromUnderscore
          : readJsonString(json, 'id'),
      firstName: readJsonString(json, 'first_name'),
      lastName: readJsonString(json, 'last_name'),
      email: readJsonString(json, 'email'),
    );
  }
}
