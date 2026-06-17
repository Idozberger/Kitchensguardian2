import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeLimitService {
  static const String _countKey = "recipe_count";
  static const String _dateKey = "recipe_date";
  static const int maxLimit = 7;

  static String _getTodayDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  static Future<bool> canSearchRecipe() async {
    final prefs = sl<SharedPreferences>();

    final today = _getTodayDate();
    final storedDate = prefs.getString(_dateKey);

    int count = prefs.getInt(_countKey) ?? 0;

    if (storedDate != today) {
      devLog("New day detected (check only)");
      return true;
    }

    devLog("Current count: $count/$maxLimit");

    if (count >= maxLimit) {
      devLog("Limit reached");
      return false;
    }

    return true;
  }

  static Future<void> incrementUsage() async {
    final prefs = sl<SharedPreferences>();

    final today = _getTodayDate();
    final storedDate = prefs.getString(_dateKey);

    int count = prefs.getInt(_countKey) ?? 0;

    if (storedDate != today) {
      await prefs.setString(_dateKey, today);
      count = 0;
      devLog("Resetting count for new day");
    }

    count++;

    await prefs.setInt(_countKey, count);

    devLog("Updated count: $count/$maxLimit");
  }
}
