import 'package:foodkitchen/core/screens/data/models/currency_model.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

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
    final Object? raw = map['currencies'];
    final List<dynamic> currenciesList = raw is List<dynamic> ? raw : [];
    return Country(
      code: readJsonString(map, 'code'),
      name: readJsonString(map, 'name'),
      currencies: currenciesList
          .map((Object? e) => Currency.fromJson(jsonObjectFromResponseData(e)))
          .toList(),
    );
  }
}
