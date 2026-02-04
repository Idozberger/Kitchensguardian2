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

  factory Currency.fromJson(Map<String, dynamic> json) =>
      Currency(code: json['code'], name: json['name'], symbol: json['symbol']);
}
