import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
