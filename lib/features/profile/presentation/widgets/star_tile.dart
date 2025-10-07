import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class ProfileStatTile extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStatTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: h(5),
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineLarge),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontSize: t(15)),
        ),
      ],
    );
  }
}
