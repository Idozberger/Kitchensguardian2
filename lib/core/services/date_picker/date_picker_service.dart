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

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
