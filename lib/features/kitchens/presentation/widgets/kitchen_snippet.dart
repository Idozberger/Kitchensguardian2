import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

Widget sectionTitle(String text, BuildContext context) {
  return Text(text, style: Theme.of(context).textTheme.headlineLarge);
}

Widget gapH(double val) => SizedBox(height: h(val));
