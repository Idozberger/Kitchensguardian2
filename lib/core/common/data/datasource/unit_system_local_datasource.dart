import 'package:shared_preferences/shared_preferences.dart';

/// Local, per-kitchen cache of the kitchen's `unit_system`, so the chosen
/// measurement system is available across app restarts without a network
/// round-trip (KG-8). The backend stays authoritative; this is a cache.
///
/// Values are stored under `unit_system_<kitchenId>`. Only auth keys are
/// cleared on logout/session-expiry, so this survives logout; it is wiped
/// only on account deletion (`SharedPreferences.clear()`).
abstract interface class UnitSystemLocalDataSource {
  Future<void> cache({required String kitchenId, required String unitSystem});

  /// Synchronous read — `SharedPreferences` reads from an in-memory cache.
  String? read({required String kitchenId});

  Future<void> clear({required String kitchenId});
}

class UnitSystemLocalDatasourceImpl implements UnitSystemLocalDataSource {
  final SharedPreferences sharedPreferences;

  UnitSystemLocalDatasourceImpl({required this.sharedPreferences});

  static const _keyPrefix = "unit_system_";

  String _key(String kitchenId) => "$_keyPrefix$kitchenId";

  @override
  Future<void> cache({
    required String kitchenId,
    required String unitSystem,
  }) async {
    if (kitchenId.isEmpty) return;
    await sharedPreferences.setString(_key(kitchenId), unitSystem);
  }

  @override
  String? read({required String kitchenId}) {
    if (kitchenId.isEmpty) return null;
    return sharedPreferences.getString(_key(kitchenId));
  }

  @override
  Future<void> clear({required String kitchenId}) async {
    if (kitchenId.isEmpty) return;
    await sharedPreferences.remove(_key(kitchenId));
  }
}
