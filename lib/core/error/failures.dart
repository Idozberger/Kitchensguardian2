import 'package:foodkitchen/core/logging/app_logger.dart';
import 'package:foodkitchen/core/services/dio/network_error_message.dart';

class Failure {
  final String message;
  const Failure(this.message);

  /// Sanitised copy for SnackBars, toasts, banners, and bloc error fields.
  String get userMessage => sanitizeUserVisibleMessage(message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// Maps an unexpected [error] to a sanitised [UnknownFailure] and records
/// a non-fatal in release for engineering visibility.
UnknownFailure unknownFailureFrom(Object error, [StackTrace? stackTrace]) {
  AppLogger.recordNonFatal(error, stackTrace, reason: 'repository_catch');
  return UnknownFailure(sanitizeUserVisibleMessage(error.toString()));
}
