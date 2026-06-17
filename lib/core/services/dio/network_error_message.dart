import 'dart:io';

import 'package:dio/dio.dart';

/// Plain-language copy for errors shown in toasts and failure messages.
String userMessageFromDioException(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    return "Can't connect in time. Check your network and try again.";
  }
  if (e.type == DioExceptionType.sendTimeout) {
    return "Couldn't send your request in time. Try again.";
  }
  if (e.type == DioExceptionType.receiveTimeout) {
    return "The server took too long to respond. Try again in a moment.";
  }
  if (e.type == DioExceptionType.connectionError ||
      e.error is SocketException) {
    return "No internet connection. Check Wi‑Fi or mobile data and try again.";
  }
  if (e.type == DioExceptionType.cancel) {
    return "Request was cancelled.";
  }
  if (e.type == DioExceptionType.badCertificate) {
    return "Secure connection failed. Try another network or update the app.";
  }

  final status = e.response?.statusCode;
  final bodyMsg = _messageFromResponseBody(e.response?.data);

  if (status != null) {
    if (bodyMsg != null && bodyMsg.isNotEmpty) {
      return _sanitizeForUser(bodyMsg);
    }
    return _messageForStatusCode(status);
  }

  if (bodyMsg != null && bodyMsg.isNotEmpty) {
    return _sanitizeForUser(bodyMsg);
  }

  return "Something went wrong. Please try again.";
}

String? _messageFromResponseBody(dynamic data) {
  if (data == null) return null;

  if (data is String) {
    final t = data.trim();
    return t.isEmpty ? null : t;
  }

  if (data is Map) {
    final m = Map<String, dynamic>.from(data);
    for (final key in [
      'message',
      'error',
      'detail',
      'msg',
      'description',
      'title',
    ]) {
      final v = m[key];
      if (v is String && v.trim().isNotEmpty) return v;
      if (v is List && v.isNotEmpty) {
        final first = v.first;
        if (first is String && first.trim().isNotEmpty) return first;
      }
    }

    final errors = m['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstVal = errors.values.first;
      if (firstVal is List && firstVal.isNotEmpty) {
        return firstVal.first.toString();
      }
      if (firstVal is String && firstVal.isNotEmpty) return firstVal;
    }
  }

  if (data is List && data.isNotEmpty) {
    final first = data.first;
    if (first is String && first.trim().isNotEmpty) return first;
    if (first is Map) {
      final msg = first['message'] ?? first['error'];
      if (msg is String && msg.trim().isNotEmpty) return msg;
    }
  }

  return null;
}

String _sanitizeForUser(String raw) => sanitizeUserVisibleMessage(raw);

/// Shared copy hardening for API bodies, platform messages, and fallbacks.
String sanitizeUserVisibleMessage(String raw) {
  var s = raw.trim();
  if (s.isEmpty) {
    return "Something went wrong. Please try again.";
  }
  if (s.length > 280) {
    s = '${s.substring(0, 277)}...';
  }
  if (s.startsWith('<')) {
    return "The server returned an error. Please try again.";
  }
  if (messageLooksUnsafeForUser(s)) {
    return "Something went wrong. Please try again.";
  }
  return s;
}

bool messageLooksUnsafeForUser(String s) {
  final lower = s.toLowerCase();
  if (lower.contains('http://') || lower.contains('https://')) {
    return true;
  }
  if (s.contains('package:') && s.contains('.dart')) {
    return true;
  }
  if (lower.contains('sql') && lower.contains('exception')) {
    return true;
  }
  if (s.contains('{') && s.contains('}') && s.length > 160) {
    return true;
  }
  final lines = s.split('\n');
  if (lines.length > 4 && lower.contains('at ')) {
    return true;
  }
  return false;
}

String _messageForStatusCode(int status) {
  switch (status) {
    case 400:
      return "This request couldn't be completed. Check your input and try again.";
    case 401:
      return "Please sign in again to continue.";
    case 403:
      return "You don't have permission to do that.";
    case 404:
      return "We couldn't find that. It may have been removed or the link is wrong.";
    case 408:
      return "The request timed out. Please try again.";
    case 409:
      return "That conflicts with the latest data. Refresh and try again.";
    case 422:
      return "Some information wasn't accepted. Check your entries and try again.";
    case 429:
      return "Too many attempts. Please wait a moment and try again.";
    case 500:
    case 502:
    case 503:
    case 504:
      return "Our servers are having trouble. Please try again in a few minutes.";
    default:
      if (status >= 500) {
        return "Our servers are having trouble. Please try again in a few minutes.";
      }
      if (status >= 400) {
        return "Something went wrong with this request. Please try again.";
      }
      return "Something went wrong. Please try again.";
  }
}
