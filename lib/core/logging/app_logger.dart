import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';

/// Production-safe logging: debug output via [devLog]; release non-fatals to Crashlytics.
abstract final class AppLogger {
  static Future<void> configureCrashReporting() async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      kReleaseMode || kProfileMode,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Forces a **fatal test crash** so you can confirm reports in the Firebase console.
  ///
  /// Only runs when **not** in release ([!kReleaseMode]) so production/store builds
  /// cannot hit this from developer UI. The process terminates immediately.
  ///
  /// **Debug:** collection is off by default; this enables it for the session first.
  static Future<void> triggerTestCrashForVerification() async {
    if (kReleaseMode) {
      return;
    }
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FirebaseCrashlytics.instance.crash();
  }

  static void recordNonFatal(
    Object error,
    StackTrace? stackTrace, {
    String reason = 'non_fatal',
  }) {
    devLog(reason, error: error, stackTrace: stackTrace);
    if (kReleaseMode) {
      unawaited(FirebaseCrashlytics.instance.log(reason));
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: false,
        ),
      );
    }
  }
}
