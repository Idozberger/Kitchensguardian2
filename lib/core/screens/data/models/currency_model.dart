import 'package:foodkitchen/core/utils/json_conversion.dart';

class Currency {
  final String code;
  final String symbol;
  final String name;

  Currency({required this.code, required this.symbol, required this.name});

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'symbol': symbol,
  };

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    code: readJsonString(json, 'code'),
    name: readJsonString(json, 'name'),
    symbol: readJsonString(json, 'symbol'),
  );
}
