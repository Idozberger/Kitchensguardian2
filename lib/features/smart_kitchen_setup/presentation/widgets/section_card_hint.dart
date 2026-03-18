import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class SectionCardHint extends StatelessWidget {
  final String hint;
  const SectionCardHint({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(left: 16, top: 0, right: 16, bottom: 0),
      child: Text(
        hint,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: Colors.black,
          fontSize: t(13),
          height: 1.5,
        ),
      ),
    );
  }
}
