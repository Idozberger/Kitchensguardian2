import 'package:flutter/services.dart';

class OnlyLettersFormatter extends TextInputFormatter {
  final int maxLength; // maximum allowed length
  final RegExp _regExp = RegExp(r'[a-zA-Z]');

  OnlyLettersFormatter({this.maxLength = 12}); // default max 20 chars

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only letters
    String filtered = newValue.text.split('').where(_regExp.hasMatch).join();

    // Restrict length
    if (filtered.length > maxLength) {
      filtered = filtered.substring(0, maxLength);
    }

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
