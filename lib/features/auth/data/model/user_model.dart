import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: readJsonString(json, 'first_name'),
      lastName: readJsonString(json, 'last_name'),
      email: readJsonString(json, 'email'),
      password: readJsonString(json, 'password'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName.isEmpty ? "N/A" : lastName,
      "email": email,
      "password": password,
    };
  }
}
