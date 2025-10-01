import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class TextspanWidget extends StatelessWidget {
  final VoidCallback onSignUpTap;
  final String text;
  final String buttonText;

  const TextspanWidget({
    super.key,
    required this.onSignUpTap,
    required this.text,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: "$text ",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
          children: [
            TextSpan(
              text: buttonText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
              recognizer: TapGestureRecognizer()..onTap = onSignUpTap,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
