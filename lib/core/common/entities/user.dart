class User {
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool? hasExpired;
  final String? expirationDate;

  User({
    this.firstName,
    this.lastName,
    this.email,
    this.expirationDate,
    this.hasExpired,
  });

  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    bool? hasExpired,
    String? expirationDate,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      hasExpired: hasExpired ?? this.hasExpired,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      hasExpired: json['has_expired'] as bool?,
      expirationDate: json['expiration_date'] as String?,
    );
  }
}
