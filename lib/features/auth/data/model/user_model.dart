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
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
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
