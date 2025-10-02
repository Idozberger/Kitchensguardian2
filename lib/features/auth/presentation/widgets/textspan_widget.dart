import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TextspanWidget extends StatelessWidget {
  final VoidCallback callback;
  final String text;
  final String buttonText;
  final Color buttonColor;
  final FontWeight? fontWeight;
  final TextStyle? style;
  const TextspanWidget({
    super.key,
    required this.callback,
    required this.text,
    required this.buttonText,
    required this.buttonColor,
    this.fontWeight = FontWeight.w700,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "$text ",
        style:
            style ??
            Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
        children: [
          TextSpan(
            text: buttonText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: buttonColor,
              fontWeight: fontWeight,
            ),
            recognizer: TapGestureRecognizer()..onTap = callback,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
