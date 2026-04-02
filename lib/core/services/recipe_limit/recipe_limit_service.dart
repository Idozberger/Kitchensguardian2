import 'dart:developer';
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
    final prefs = await SharedPreferences.getInstance();

    final today = _getTodayDate();
    final storedDate = prefs.getString(_dateKey);

    int count = prefs.getInt(_countKey) ?? 0;

    if (storedDate != today) {
      log("New day detected (check only)");
      return true;
    }

    log("Current count: $count/$maxLimit");

    if (count >= maxLimit) {
      log("Limit reached");
      return false;
    }

    return true;
  }

  static Future<void> incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();

    final today = _getTodayDate();
    final storedDate = prefs.getString(_dateKey);

    int count = prefs.getInt(_countKey) ?? 0;

    if (storedDate != today) {
      await prefs.setString(_dateKey, today);
      count = 0;
      log("Resetting count for new day");
    }

    count++;

    await prefs.setInt(_countKey, count);

    log("Updated count: $count/$maxLimit");
  }
}
