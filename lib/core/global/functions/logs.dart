import 'package:flutter/material.dart';

void logWarning(Object message) {
  _logWithColor(message, '📢', 33);
}

void logInfo(Object message) {
  _logWithColor(message, '📌', 34);
}

void _logWithColor(Object message, String label, int colorCode) {
  final String separator =
      "\x1B[${colorCode}m==========================================================================================\x1B[0m";
  debugPrint(separator);
  debugPrint('\x1B[${colorCode}m[$label] $message\x1B[0m');
  debugPrint(separator);
}
