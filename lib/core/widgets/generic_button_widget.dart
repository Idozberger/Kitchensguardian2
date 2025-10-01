import 'package:flutter/material.dart';

class GenericButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  GenericButtonWidget({
    super.key,
    required this.onPressed,

    required this.text,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: isLoading
            ? CircularProgressIndicator()
            : Text(text, style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
