import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_premium_card_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/drawer_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, userState) {
        return Drawer(
          width: w(307),
          child: SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(context, userState),
                  gap(height: 20),
                  const PremiumCardWidget(),
                  gap(height: 20),
                  _buildDrawerItems(context),
                  const Spacer(),
                  _buildLogoutButton(context),
                  gap(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(BuildContext context, UserState userState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: h(35),
          backgroundImage: AssetImage(AppAssets.avatar),
        ),
        gap(height: 15),
        Text(
          "${userState.firstName} ${userState.lastName}",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        gap(height: 5),
        Text(
          userState.email,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: t(15),
            color: const Color(0xff787878),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    return Column(
      children: [
        DrawerListTile(
          title: "Favourite",
          iconPath: AppAssets.favouriteSvg,
          onTap: () {
            context.push(Routes.favouriteFood);
          },
        ),
        DrawerListTile(
          title: "My Kitchen Members",
          iconPath: AppAssets.myKitchenMember,
          onTap: () {
            context.push(Routes.myKitchenMembers);
          },
        ),
        DrawerListTile(
          title: "Get Referral Code",
          iconPath: AppAssets.referralSvg,
          onTap: () {
            const referralCode = "REF12345";
            final message = "Use my referral code: $referralCode";
            // ignore: deprecated_member_use
            Share.share(message, subject: "Kitchen Guardian");
          },
        ),

        DrawerListTile(
          title: "Scan History",
          iconPath: AppAssets.historySvg,
          onTap: () => context.push(Routes.scanHistory),
        ),
        DrawerListTile(
          title: "Kitchens",
          iconPath: AppAssets.kitchenSvg,
          onTap: () => context.push(Routes.kitchen),
        ),
        DrawerListTile(
          title: "Terms & Conditions",
          iconPath: AppAssets.termsAndConditionSvg,
          onTap: () {
            AppToast.show(
              "We will navigate user to our privacypolicy and termsAndCondition page",
              ToastType.success,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: w(150),
      height: h(40),
      child: ElevatedButton.icon(
        onPressed: () {
          context.push(Routes.logout);
          // context.push(Routes.noInternet);
          // context.push(Routes.notFound404);
        },
        icon: SvgPicture.asset(AppAssets.logoutSvg),
        label: Text(
          "Log Out",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: t(14),
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
