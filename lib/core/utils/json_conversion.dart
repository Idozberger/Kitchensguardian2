import 'dart:convert';

/// Normalizes Dio / manual JSON values to a typed map for strict analysis.
Map<String, dynamic> jsonObjectFromResponseData(Object? data) {
  if (data == null) return {};
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is String) {
    final decoded = jsonDecode(data);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  return {};
}

/// Wraps API / JSON error payloads so `throw` is valid under strict inference.
Exception apiExceptionFrom(Object? value) {
  if (value is Exception) return value;
  return Exception(value?.toString() ?? 'Unknown error');
}

String readJsonString(
  Map<String, dynamic> m,
  String key, {
  String fallback = '',
}) {
  final Object? v = m[key];
  if (v == null) return fallback;
  if (v is String) return v;
  return v.toString();
}

bool readJsonBool(Map<String, dynamic> m, String key, {bool fallback = false}) {
  final Object? v = m[key];
  if (v is bool) return v;
  return fallback;
}

int readJsonInt(Map<String, dynamic> m, String key, {int fallback = 0}) {
  final Object? v = m[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  return fallback;
}

double readJsonDouble(
  Map<String, dynamic> m,
  String key, {
  double fallback = 0,
}) {
  final Object? v = m[key];
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return fallback;
}

List<String> readJsonStringList(Map<String, dynamic> m, String key) {
  final Object? v = m[key];
  if (v is! List) return [];
  return v.map((Object? e) => e?.toString() ?? '').toList();
}
