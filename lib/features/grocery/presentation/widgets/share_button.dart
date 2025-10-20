import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final String shareString;
  const ShareButton({super.key, required this.shareString});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: h(40),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        onPressed: () async {
          await Share.share(
            "Grocery List\n$shareString",
            subject: 'My Grocery List',
          );
        },
        icon: SvgPicture.asset(AppAssets.shareSvg),
        label: Text(
          "Share List",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: t(14),
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
