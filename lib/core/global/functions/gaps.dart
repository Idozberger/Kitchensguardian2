import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:flutter/material.dart';

EdgeInsets get gapZero => EdgeInsets.zero;

EdgeInsets gapAll(double value) =>
    EdgeInsets.fromLTRB(w(value), h(value), w(value), h(value));

SizedBox gapHorizontal(double value) => SizedBox(width: w(value));

SizedBox gapVertical(double value) => SizedBox(height: h(value));

EdgeInsets gapSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
    EdgeInsets.symmetric(horizontal: w(horizontal), vertical: h(vertical));

EdgeInsets gapOnly({
  double left = 0.0,
  double right = 0.0,
  double bottom = 0.0,
  double top = 0.0,
}) => EdgeInsets.only(
  left: w(left),
  right: w(right),
  bottom: h(bottom),
  top: h(top),
);
