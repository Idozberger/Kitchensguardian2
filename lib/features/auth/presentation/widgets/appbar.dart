import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subTitle;
  final bool leading;
  final bool centerTitle;
  final double horizontalPad;
  final double preferedHeight;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.subTitle,
    this.leading = true,
    this.horizontalPad = 20,
    required this.centerTitle,
    this.preferedHeight = 50,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      leading: leading
          ? Row(
              children: [
                SizedBox(width: w(16)),
                CircularIconButton(
                  iconAsset: AppAssets.backArrowiOS,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            )
          : null,
      centerTitle: centerTitle,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: preferredSize,
        child: Padding(
          padding: gapSymmetric(horizontal: horizontalPad),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineLarge),
                gap(height: 4),
                Text(
                  subTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + h(preferedHeight));
}
