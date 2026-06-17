import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:foodkitchen/core/error/user_facing_error.dart';
import 'package:foodkitchen/core/logging/app_logger.dart';
import 'package:foodkitchen/core/services/dio/network_error_message.dart';

abstract final class UserFacingErrorMapper {
  static UserFacingError fromDio(DioException e) {
    return UserFacingError(userMessageFromDioException(e), cause: e);
  }

  static UserFacingError fromPlatform(
    PlatformException e, {
    String fallbackUserMessage = 'Something went wrong. Please try again.',
  }) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').trim();
    if (code == 'camera_access_denied' ||
        code == 'permission_denied' ||
        message.toLowerCase().contains('permission')) {
      return UserFacingError(
        'Permission is required for this action. Check your device settings.',
        cause: e,
      );
    }
    if (message.isEmpty || _looksInternal(message)) {
      return UserFacingError(fallbackUserMessage, cause: e);
    }
    return UserFacingError(sanitizeUserVisibleMessage(message), cause: e);
  }

  static UserFacingError fromFirebase(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (error is FirebaseException) {
      return UserFacingError(
        _firebaseUserMessage(error.code),
        cause: error,
        stackTrace: stackTrace,
      );
    }
    return fromUnknown(error, stackTrace);
  }

  static UserFacingError fromUnknown(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    AppLogger.recordNonFatal(error, stackTrace, reason: 'user_facing_unknown');
    return UserFacingError(
      sanitizeUserVisibleMessage(error.toString()),
      cause: error,
      stackTrace: stackTrace,
    );
  }

  static String _firebaseUserMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return "You don't have permission to do that.";
      case 'unavailable':
      case 'deadline-exceeded':
        return "The service is temporarily unavailable. Try again in a moment.";
      case 'not-found':
        return "We couldn't find that. It may have been removed.";
      case 'cancelled':
        return "The request was cancelled.";
      default:
        return "Something went wrong. Please try again.";
    }
  }

  static bool _looksInternal(String raw) =>
      messageLooksUnsafeForUser(raw);
}
