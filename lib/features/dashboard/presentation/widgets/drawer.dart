import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/drawer_tile.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: w(307),
      child: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: h(35),
                backgroundImage: AssetImage(AppAssets.avatar),
              ),
              SizedBox(height: h(15)),
              Text(
                "Emily David",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: h(5)),
              Text(
                "fakemail@example.com",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(15),
                  color: Color(0xff787878),
                ),
              ),
              SizedBox(height: h(20)),

              Container(
                width: double.infinity,
                padding: gapSymmetric(horizontal: 15, vertical: 21),
                decoration: BoxDecoration(
                  color: Color(0xffF6A500),
                  borderRadius: BorderRadius.circular(h(12)),
                  image: DecorationImage(
                    image: AssetImage(AppAssets.premiumBg),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Unlock Premium",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      "Features!",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: h(5)),
                    Text(
                      "Subscribe now and enjoy a more cooking experience with premium features.",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: t(10),
                            color: Colors.black,
                          ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h(20)),

              DrawerListTile(
                title: "Favourite",
                iconPath: AppAssets.favouriteSvg,
                onTap: () {
                  // Handle navigation
                },
              ),
              DrawerListTile(
                title: "My Kitchen Members",
                iconPath: AppAssets.myKitchenMember,
                onTap: () {
                  // Handle navigation
                },
              ),
              DrawerListTile(
                title: "Get Referral Code",
                iconPath: AppAssets.referralSvg,
                onTap: () {
                  // Handle navigation
                },
              ),
              DrawerListTile(
                title: "Scan History",
                iconPath: AppAssets.historySvg,
                onTap: () {
                  context.push(Routes.scanHistory);
                },
              ),
              DrawerListTile(
                title: "Kitchens",
                iconPath: AppAssets.kitchenSvg,
                onTap: () {
                  // Handle navigation
                },
              ),
              DrawerListTile(
                title: "Terms & Conditions",
                iconPath: AppAssets.termsAndConditionSvg,
                onTap: () {
                  // Handle navigation
                },
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go(Routes.signIn);
                  },
                  icon: SvgPicture.asset(AppAssets.logoutSvg),
                  label: Text(
                    "Log Out",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: t(14),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
