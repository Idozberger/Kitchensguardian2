import 'dart:ui';
import 'package:flutter/material.dart';

double _referWidth = 375;
double _referHeight = 812;
final view = PlatformDispatcher.instance.implicitView!;
final viewHeight = view.physicalSize.height / view.devicePixelRatio;
final viewWidth = view.physicalSize.width / view.devicePixelRatio;

double h(double value) {
  return viewHeight * (value / _referHeight);
}

double w(double value) {
  return viewWidth * (value / _referWidth);
}

double t(double value) {
  return viewHeight * (value / _referHeight);
}

Size textSize(Text text) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text.data, style: text.style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}
