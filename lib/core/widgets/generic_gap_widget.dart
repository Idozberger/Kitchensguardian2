import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

Widget gap({double height = 0, double width = 0}) {
  return SizedBox(height: h(height), width: w(width));
}
