import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class KitchenTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String email;
  final String membersText;
  final Color membersColor;
  final double fontSize;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final VoidCallback? onTileTap;
  final VoidCallback? onButtonPressed;
  final String buttonText;
  final double buttonWidth;
  final double buttonHeight;

  const KitchenTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.email,
    required this.membersText,
    this.membersColor = Colors.grey,
    this.fontSize = 10,
    this.titleFontSize = 15,
    this.titleFontWeight = FontWeight.w500,
    this.onTileTap,
    this.onButtonPressed,
    this.buttonText = "View",
    this.buttonWidth = 90,
    this.buttonHeight = 23,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(imagePath, width: w(40), height: h(38)),
            SizedBox(width: w(5)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextspanWidget(
                  callback: onTileTap ?? () {},
                  text: title,
                  buttonText: membersText,
                  buttonColor: membersColor,
                  fontSize: t(fontSize),
                  fontSizeTitle: t(titleFontSize),
                  titleFontWeight: titleFontWeight,
                ),
                Text(
                  email,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: t(11),
                  ),
                ),
              ],
            ),
          ],
        ),
        GenericButtonWidget(
          onPressed: onButtonPressed ?? () => context.pop(),
          text: buttonText,
          width: w(buttonWidth),
          height: h(buttonHeight),
        ),
      ],
    );
  }
}
