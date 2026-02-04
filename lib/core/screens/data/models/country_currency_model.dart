import 'package:foodkitchen/core/screens/data/models/currency_model.dart';

class Country {
  final String code;
  final String name;
  final List<Currency> currencies;

  Country({required this.code, required this.name, required this.currencies});

  Map<String, dynamic> toMap() => {
    'code': code,
    'name': name,
    'currencies': currencies.map((c) => c.toJson()).toList(),
  };

  factory Country.fromMap(Map<String, dynamic> map) {
    final currenciesList = map['currencies'] as List<dynamic>? ?? [];
    return Country(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      currencies: currenciesList.map((e) => Currency.fromJson(e)).toList(),
    );
  }
}
