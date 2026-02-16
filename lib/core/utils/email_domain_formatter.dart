import 'package:flutter/services.dart';

class SingleAtSingleDotAfterAtFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // No spaces allowed
    if (text.contains(' ')) {
      return oldValue;
    }

    // Only one '@'
    if ('@'.allMatches(text).length > 1) {
      return oldValue;
    }

    // If '@' exists, restrict dots AFTER '@'
    if (text.contains('@')) {
      final domainPart = text.split('@').last;

      // Only one dot after '@'
      if ('.'.allMatches(domainPart).length > 1) {
        return oldValue;
      }

      // Domain cannot start with dot
      if (domainPart.startsWith('.')) {
        return oldValue;
      }
    }

    return newValue;
  }
}

bool validateEmailLength({
  required String email,
  required void Function(String message) onError,
}) {
  if (!email.contains('@')) return true;

  final parts = email.split('@');
  if (parts.length != 2) return true;

  final localPart = parts[0];
  final domainPart = parts[1];

  // BEFORE @
  if (localPart.length > 44) {
    onError("Email name cannot exceed 44 characters");
    return false;
  }

  // AFTER @
  if (domainPart.length > 24) {
    onError("Email domain cannot exceed 24 characters");
    return false;
  }

  return true; // ✅ length OK
}
