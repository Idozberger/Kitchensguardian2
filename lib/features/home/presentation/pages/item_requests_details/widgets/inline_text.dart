import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class InlineText extends StatelessWidget {
  final String text;

  const InlineText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: t(14),
        color: const Color(0xff787878),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
