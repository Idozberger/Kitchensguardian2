import 'package:flutter/services.dart';

class NoSpacePasswordFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Block spaces
    if (newValue.text.contains(' ')) {
      return oldValue;
    }
    return newValue;
  }
}
