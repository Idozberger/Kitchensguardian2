import 'package:flutter/foundation.dart';

/// Development logging only ([kDebugMode]).
///
/// Release and profile builds: these functions are no-ops, so auth tokens and
/// verbose diagnostics are never emitted from here. Network request/response
/// bodies in [DioHelper] are also gated on [kDebugMode] only.
///
/// Output uses [debugPrint] (IDE, `flutter run`, logcat as `I/flutter`).
void devLog(
  String message, {
  String name = '',
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;
  final String line = name.isEmpty ? message : '[$name] $message';
  debugPrint(line, wrapWidth: 1024);
  if (error != null) {
    debugPrint('$error', wrapWidth: 1024);
  }
  if (stackTrace != null) {
    debugPrint('$stackTrace', wrapWidth: 1024);
  }
}

/// [debugPrint] only when [kDebugMode] is true.
void devPrint(String? message, {int? wrapWidth}) {
  if (!kDebugMode) return;
  debugPrint(message, wrapWidth: wrapWidth);
}
