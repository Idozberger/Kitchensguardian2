import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

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
  final bool isMember;
  final bool allUsersView;
  final VoidCallback onSecondaryActionTap;

  const KitchenTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.email,
    required this.onSecondaryActionTap,
    required this.membersText,
    this.membersColor = Colors.grey,
    this.fontSize = 10,
    this.titleFontSize = 15,
    this.titleFontWeight = FontWeight.w500,
    this.onTileTap,
    this.onButtonPressed,
    this.buttonText = "Show",
    this.buttonWidth = 90,
    this.buttonHeight = 24,

    this.isMember = false,
    this.allUsersView = false,
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
            SizedBox(
              width: w(158),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                    textAlign: TextAlign.left,
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
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (buttonText.toLowerCase().trim() == "active")
              Container(
                padding: gapSymmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(w(88)),
                ),
                child: Text(
                  "Active",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: t(12),
                    color: Colors.black,
                  ),
                ),
              ),

            if (allUsersView)
              const SizedBox()
            else if (buttonText.toLowerCase().trim() != "active") ...[
              gap(height: 6),

              Row(
                children: [
                  TextButton(
                    onPressed: onButtonPressed,
                    child: CircularIconButton(
                      iconAsset: AppAssets.eyeSvg,
                      iconColor: Colors.black,
                    ),
                  ),

                  if (isMember)
                    GestureDetector(
                      onTap: onSecondaryActionTap,
                      child: CircularIconButton(
                        iconAsset: AppAssets.logoutSvg,
                        iconColor: Colors.red,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: onSecondaryActionTap,
                      child: CircularIconButton(
                        iconAsset: AppAssets.deleteSvg,
                        iconColor: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}
