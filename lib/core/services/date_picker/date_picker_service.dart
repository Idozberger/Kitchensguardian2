import 'package:flutter/material.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class DatePickerService {
  static Future<String?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      return "${picked.year}-${_twoDigits(picked.month)}-${_twoDigits(picked.day)}";
    }
    return null;
  }

  static Future<String?> updateExpireDate({
    required BuildContext context,
    DateTime? initialDate,
    required String selectedDateString,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: parseSelectedDate(selectedDateString),
      firstDate: firstDate ?? now,
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      return "${picked.year}-${_twoDigits(picked.month)}-${_twoDigits(picked.day)}";
    }
    return null;
  }

  static DateTime parseSelectedDate(String value) {
    final DateTime now = DateTime.now();

    // Case 1: yyyy-MM-dd
    try {
      return DateTime.parse(value);
    } catch (_) {}

    // Case 2: relative values
    final lower = value.toLowerCase();

    if (lower.contains('day')) {
      final days = int.parse(lower.split(' ').first);
      return now.add(Duration(days: days));
    }

    if (lower.contains('week')) {
      final weeks = int.parse(lower.split(' ').first);
      return now.add(Duration(days: weeks * 7));
    }

    if (lower.contains('month')) {
      final months = int.parse(lower.split(' ').first);
      return DateTime(now.year, now.month + months, now.day);
    }

    // fallback
    return now;
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
