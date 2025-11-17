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
  final TextAlign? textAlign;
  final bool isLoading;

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
    this.textAlign = TextAlign.center,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: _getTextAlignment(),
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style:
                style ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: titleFontWeight,
                  fontSize: fontSizeTitle,
                ),
          ),
        ),
        TextButton(
          onPressed: callback,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            " $buttonText",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: buttonColor,
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }

  MainAxisAlignment _getTextAlignment() {
    switch (textAlign) {
      case TextAlign.left:
        return MainAxisAlignment.start;
      case TextAlign.right:
        return MainAxisAlignment.end;
      case TextAlign.center:
      default:
        return MainAxisAlignment.center;
    }
  }
}
