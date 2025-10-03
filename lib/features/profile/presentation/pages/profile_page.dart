import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_premium_card_widget.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: gapSymmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(),
              gap(height: 20),
              PremiumCardWidget(isGoProButtonEnabled: true),
              gap(height: 20),
              UpperTile(
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Management",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    gap(height: 20),
                    _buildListTile(
                      context,
                      assetPath: AppAssets.lockSvg,
                      title: "Password",
                      subTitle: "Change password",
                      callback: () {
                        context.push(Routes.changePassword);
                      },
                    ),
                    gap(height: 20),
                    _buildListTile(
                      context,
                      assetPath: AppAssets.signoutSvg,
                      title: "Sign Out",
                      subTitle: "Sign out of your account",
                      callback: () {
                        context.go(Routes.signIn);
                      },
                    ),
                  ],
                ),
              ),
              gap(height: 20),
              UpperTile(
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Management",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    gap(height: 20),
                    _buildListTile(
                      context,
                      assetPath: AppAssets.favouriteSvg,
                      title: "Food Preferences",
                      subTitle: "Check your selected favorite food",
                      callback: () {},
                    ),
                    gap(height: 20),
                    _buildListTile(
                      context,
                      assetPath: AppAssets.restorePurchaseSvg,
                      title: "Restore Purchases",
                      subTitle: "",
                      callback: () {},
                    ),
                  ],
                ),
              ),
              gap(height: 20),
              UpperTile(
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "System",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    gap(height: 20),

                    _buildListTile(
                      context,
                      assetPath: AppAssets.notificationSvg,
                      title: "Notifications",
                      subTitle: "",
                      callback: () {},
                    ),
                  ],
                ),
              ),
              gap(height: 20),
              UpperTile(
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recommend",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    gap(height: 20),

                    _buildListTile(
                      context,
                      assetPath: AppAssets.likeSvg,
                      title: "Tell a friend!",
                      subTitle: "",
                      callback: () {},
                    ),
                    gap(height: 20),

                    _buildListTile(
                      context,
                      assetPath: AppAssets.starSvg,
                      title: "Rate app",
                      subTitle: "",
                      callback: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildListTile(
    BuildContext context, {
    required String assetPath,
    required String title,
    required String subTitle,
    required VoidCallback callback,
  }) {
    return ListTile(
      onTap: () => callback(),
      dense: true,
      contentPadding: gapZero,
      leading: SvgPicture.asset(assetPath),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineLarge!.copyWith(fontSize: t(15)),
      ),
      subtitle: subTitle.isEmpty
          ? null
          : Padding(
              padding: gapOnly(top: 5),
              child: Text(
                subTitle,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontSize: t(15),
                  color: Color(0xff787878),
                ),
              ),
            ),
    );
  }
}

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
          SizedBox(height: h(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              ProfileStatTile(title: "Meals Planned", value: "47"),
              ProfileStatTile(title: "Shopping Lists", value: "89"),
            ],
          ),
          SizedBox(height: h(20)),
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
                  fontSize: t(14),
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

class ProfileStatTile extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStatTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: h(5),
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineLarge),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontSize: t(15)),
        ),
      ],
    );
  }
}
