part of 'package:foodkitchen/app/app_router.dart';

bool readRouteBool(
  Map<String, dynamic>? map,
  String key, {
  bool fallback = false,
}) {
  final Object? v = map?[key];
  if (v is bool) return v;
  return fallback;
}

String readRouteString(
  Map<String, dynamic>? map,
  String key, {
  String fallback = '',
}) {
  final Object? v = map?[key];
  if (v == null) return fallback;
  if (v is String) return v;
  return v.toString();
}

DashboardEntryType readRouteDashboardEntryType(Map<String, dynamic>? map) {
  final Object? v = map?['entryType'];
  if (v is DashboardEntryType) return v;
  return DashboardEntryType.normal;
}

List<PantryItem> readRoutePantryItems(Map<String, dynamic>? map) {
  final Object? v = map?['pantryItems'];
  if (v is List<PantryItem>) return List<PantryItem>.from(v);
  if (v is List) return v.whereType<PantryItem>().toList();
  return const [];
}

List<IngredientEntity> readRouteIngredientEntities(Map<String, dynamic>? map) {
  final Object? v = map?['selectedIngredients'];
  if (v is List<IngredientEntity>) return List<IngredientEntity>.from(v);
  if (v is List) return v.whereType<IngredientEntity>().toList();
  return const [];
}
