import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

enum ToastType { success, error, warning, info }

class AppToast {
  static void show(
    String message,
    ToastType type, {
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Color bgColor;

    switch (type) {
      case ToastType.success:
        bgColor = Colors.green;

        break;
      case ToastType.error:
        bgColor = Colors.red;

        break;
      case ToastType.warning:
        bgColor = Colors.orange;

        break;
      case ToastType.info:
      default:
        bgColor = Colors.blue;
    }

    Fluttertoast.showToast(
      msg: " $message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: t(12),
    );
  }
}
