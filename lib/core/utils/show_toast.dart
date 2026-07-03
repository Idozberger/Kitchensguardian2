import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

enum ToastType { success, error, warning, info }

class AppToast {
  /// Duration for important toasts (e.g. "account already registered") that
  /// users need extra time to read. Android supports only SHORT/LONG.
  static const Toast longDuration = Toast.LENGTH_LONG;

  /// iOS/web toast lifetime (seconds) paired with [longDuration].
  static const int longDurationIosSeconds = 4;

  static void show(
    String message,
    ToastType type, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    int timeInSecForIosWeb = 1,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    Color bgColor;

    switch (type) {
      case ToastType.success:
        bgColor = Colors.green;
      case ToastType.error:
        bgColor = Colors.red;
      case ToastType.warning:
        bgColor = Colors.orange;
      case ToastType.info:
        bgColor = Colors.blue;
    }

    Fluttertoast.showToast(
      msg: " $message",
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: timeInSecForIosWeb,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: t(12),
    );
  }
}
