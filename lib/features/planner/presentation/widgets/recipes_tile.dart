import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class RecipeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? errorText;
  final String? imagePath;
  final String trailingIcon;
  final bool selected;
  final bool isDeletedIcon;

  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;

  const RecipeTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    required this.trailingIcon,
    this.selected = false,
    this.isDeletedIcon = false,

    this.errorText,
    this.onTap,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Ink(
        padding: EdgeInsets.all(h(0)),
        decoration: BoxDecoration(
          color: selected ? Color(0xffFFFBEB) : null,
          borderRadius: BorderRadius.circular(h(12)),
          border: Border.all(
            color: selected ? AppColors.amberLight : Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(h(10)),
              child: imagePath != null && imagePath!.isNotEmpty
                  ? CachedNetworkImage(imageUrl: imagePath!)
                  : Image.asset(
                      AppAssets.onBoardingSliderBg01,
                      width: w(78),
                      height: h(78),
                      fit: BoxFit.cover,
                    ),
            ),

            SizedBox(width: w(12)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontSize: t(15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: h(2)),

                  Text(
                    subtitle,
                    maxLines: errorText != null && errorText!.isNotEmpty
                        ? 2
                        : 3,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (errorText != null && errorText!.isNotEmpty) ...[
                    SizedBox(height: h(4)),
                    Text(
                      errorText!,
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(
                            color: Colors.red,
                            fontSize: t(10),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: w(12)),

            GestureDetector(
              onTap: onTrailingTap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isDeletedIcon
                      ? Border.all(color: Color(0xffD4D2D2), width: 1.5)
                      : null,
                ),
                child: CircleAvatar(
                  radius: h(12),
                  backgroundColor: isDeletedIcon
                      ? Colors.white
                      : AppColors.primaryColor,
                  child: SvgPicture.asset(trailingIcon, height: h(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
