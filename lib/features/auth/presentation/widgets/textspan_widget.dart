import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TextspanWidget extends StatelessWidget {
  final VoidCallback callback;
  final String text;
  final String buttonText;
  final Color buttonColor;
  final FontWeight? fontWeight;
  final TextStyle? style;
  final double? fontSize;
  final double? fontSizeTitle;
  final FontWeight? titleFontWeight;
  const TextspanWidget({
    super.key,
    required this.callback,
    required this.text,
    required this.buttonText,
    required this.buttonColor,
    this.fontWeight = FontWeight.w700,
    this.style,
    this.fontSize,
    this.fontSizeTitle,
    this.titleFontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "$text ",
        style:
            style ??
            Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: titleFontWeight,
              fontSize: fontSizeTitle,
            ),
        children: [
          TextSpan(
            text: buttonText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: buttonColor,
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
            recognizer: TapGestureRecognizer()..onTap = callback,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
