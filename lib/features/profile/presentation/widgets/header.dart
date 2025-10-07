import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/profile/presentation/widgets/star_tile.dart';
import 'package:go_router/go_router.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AppAssets.avatar, width: w(72), height: h(72)),
              SizedBox(width: w(20)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: h(5),
                children: [
                  Text(
                    "Emily David",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    "fakemail@example.com",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.copyWith(fontSize: t(15)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: h(5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              ProfileStatTile(title: "Meals Planned", value: "47"),
              ProfileStatTile(title: "Shopping Lists", value: "89"),
            ],
          ),
          SizedBox(height: h(15)),
          SizedBox(
            width: double.infinity,
            height: h(40),
            child: OutlinedButton.icon(
              onPressed: () {
                context.push(Routes.editProfile);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              icon: SvgPicture.asset(
                AppAssets.editSvg,
                color: AppColors.primaryColor,
              ),
              label: Text(
                "Edit Profile",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(13),
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
