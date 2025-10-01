import 'package:flutter/material.dart';

logError(Object message) {
  _logWithColor(message, '❌', 31);
}

logSuccess(Object message) {
  _logWithColor(message, '✅', 32);
}

logWarning(Object message) {
  _logWithColor(message, '📢', 33);
}

logInfo(Object message) {
  _logWithColor(message, '📌', 34);
}

_logWithColor(Object message, String label, int colorCode) {
  final String separator =
      "\x1B[${colorCode}m==========================================================================================\x1B[0m";
  debugPrint(separator);
  debugPrint('\x1B[${colorCode}m[$label] $message\x1B[0m');
  debugPrint(separator);
}
