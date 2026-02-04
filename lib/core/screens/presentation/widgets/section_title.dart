import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontSize: t(16),
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}
