import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_premium_card_widget.dart';
import 'package:foodkitchen/features/profile/presentation/widgets/header.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: gapSymmetric(horizontal: 20, vertical: 15),
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
                    gap(height: 10),
                    _buildListTile(
                      context,
                      assetPath: AppAssets.lockSvg,
                      title: "Password",
                      subTitle: "Change password",
                      callback: () {
                        context.push(Routes.changePassword);
                      },
                    ),
                    gap(height: 5),
                    _buildListTile(
                      context,
                      assetPath: AppAssets.signoutSvg,
                      title: "Sign Out",
                      subTitle: "Sign out of your account",
                      callback: () {
                        context.push(Routes.logout);
                      },
                    ),
                    gap(height: 5),
                    _buildListTile(
                      context,
                      assetPath: AppAssets.restorePurchaseSvg,
                      title: "Restore Purchases",
                      subTitle: "",
                      callback: () {
                        AppToast.show("Restore Purchases", ToastType.success);
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
                      "System",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    gap(height: 10),

                    _buildListTile(
                      context,
                      assetPath: AppAssets.notificationSvg,
                      title: "Notifications",
                      subTitle: "",
                      callback: () {
                        context.push(Routes.notification);
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
                      "Recommend",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    gap(height: 10),

                    _buildListTile(
                      context,
                      assetPath: AppAssets.likeSvg,
                      title: "Tell a friend!",
                      subTitle: "",
                      callback: () {
                        AppToast.show("Tell a friend!", ToastType.success);
                      },
                    ),
                    gap(height: 5),

                    _buildListTile(
                      context,
                      assetPath: AppAssets.starSvg,
                      title: "Rate app",
                      subTitle: "",
                      callback: () {
                        AppToast.show("Rate app", ToastType.success);
                      },
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
      leading: SvgPicture.asset(assetPath, height: h(18)),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineLarge!.copyWith(fontSize: t(13)),
      ),
      subtitle: subTitle.isEmpty
          ? null
          : Padding(
              padding: gapOnly(top: 5),
              child: Text(
                subTitle,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontSize: t(13),
                  color: Color(0xff787878),
                ),
              ),
            ),
    );
  }
}
