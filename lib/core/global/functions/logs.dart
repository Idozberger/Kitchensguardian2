import 'package:foodkitchen/core/utils/dev_logging.dart';

void logWarning(Object message) {
  _logWithColor(message, '📢', 33);
}

void _logWithColor(Object message, String label, int colorCode) {
  final String separator =
      "\x1B[${colorCode}m==========================================================================================\x1B[0m";
  devPrint(separator);
  devPrint('\x1B[${colorCode}m[$label] $message\x1B[0m');
  devPrint(separator);
}
