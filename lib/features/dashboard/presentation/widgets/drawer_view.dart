import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_otp_widget.dart';
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
                  _buildProfileSection(context),
                  gap(height: 20),
                  const PremiumCardWidget(),
                  gap(height: 20),
                  _buildDrawerItems(context),
                  gap(height: 10),
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

  Widget _buildProfileSection(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: h(35),
              backgroundImage:
                  state.profilePictureFilePath != null &&
                      state.profilePictureFilePath!.isNotEmpty
                  ? MemoryImage(state.profilePictureFilePath!)
                  : AssetImage(AppAssets.avatar),
            ),
            gap(height: 15),
            Text(
              "${state.firstName} ${state.lastName}",
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                overflow: TextOverflow.ellipsis,
              ),
            ),
            gap(height: 5),
            Text(
              state.email,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: t(15),
                color: const Color(0xff787878),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, state) {
        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                DrawerListTile(
                  title: "Favourite",
                  iconPath: AppAssets.favouriteSvg,
                  onTap: () {
                    context.push(Routes.favouriteFood);
                  },
                ),
                Divider(color: Color(0xffF4F4F4)),
                DrawerListTile(
                  title: "My Kitchen Members",
                  iconPath: AppAssets.myKitchenMember,
                  onTap: () {
                    if (state.activeKitchenId.isNotEmpty) {
                      context.push(Routes.myKitchenMembers);
                    } else {
                      AppToast.show(
                        "Please join or create kitchen",
                        ToastType.error,
                      );
                    }
                  },
                ),
                Divider(color: Color(0xffF4F4F4)),
                DrawerListTile(
                  title: "Country/Currency",
                  iconPath: AppAssets.countrySvg,
                  onTap: () {
                    context.pushNamed(
                      Routes.countryAndCurrencySetup,
                      extra: true,
                    );
                  },
                ),
                Divider(color: Color(0xffF4F4F4)),
                DrawerListTile(
                  title: "Get Kitchen Code",
                  iconPath: AppAssets.referralSvg,
                  onTap: () async {
                    Navigator.pop(context);
                    if (state.activeKitchenId.isNotEmpty) {
                      if (state.invitationCode.isNotEmpty) {
                        debugPrint("inivitaion code ${state.invitationCode}");
                        _showRefferalCodeDialog(context, state.invitationCode);
                      } else {
                        AppToast.show(
                          "Kitchen members cannot invite others or access the invitation code.",
                          ToastType.error,
                        );
                      }
                    } else {
                      AppToast.show(
                        "Please join or create kitchen",
                        ToastType.error,
                      );
                    }
                  },
                ),
                Divider(color: Color(0xffF4F4F4)),
                DrawerListTile(
                  title: "Scan History",
                  iconPath: AppAssets.historySvg,
                  onTap: () {
                    if (state.activeKitchenId.isNotEmpty) {
                      context.push(Routes.scanHistory);
                    } else {
                      AppToast.show(
                        "Please join or create kitchen",
                        ToastType.error,
                      );
                    }
                  },
                ),
                Divider(color: Color(0xffF4F4F4)),
                DrawerListTile(
                  title: "Rescan Kitchen",
                  iconPath: AppAssets.reScanSvg,
                  onTap: () {
                    context.pushNamed(Routes.smartKitchenSetup, extra: true);
                  },
                ),
                Divider(color: Color(0xffF4F4F4)),
                DrawerListTile(
                  title: "Kitchens",
                  iconPath: AppAssets.kitchenSvg,
                  onTap: () => context.push(Routes.kitchen),
                ),
                Divider(color: Color(0xffF4F4F4)),
                DrawerListTile(
                  title: "Location",
                  iconPath: AppAssets.pantrySvg,
                  color: Colors.black,
                  onTap: () => context.push(Routes.allStorageArea),
                ),
                Divider(color: Color(0xffF4F4F4)),
                DrawerListTile(
                  title: "Terms & Conditions",
                  iconPath: AppAssets.termsAndConditionSvg,
                  onTap: () {
                    AppToast.show("Coming Soon!", ToastType.success);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: w(150),
      height: h(40),
      child: ElevatedButton.icon(
        onPressed: () {
          context.push(Routes.logout);
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

  Future<dynamic> _showRefferalCodeDialog(
    BuildContext context,
    String invitationCode,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GenericDialog(
          borderRadius: h(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              gap(height: 12),
              Text(
                "Invite a friend!",
                style: Theme.of(context).textTheme.headlineLarge!,
              ),
              gap(height: h(10)),
              Text(
                "Share this referral link to your friends and followers",
                style: Theme.of(context).textTheme.headlineSmall!,
                textAlign: TextAlign.center,
              ),
              gap(height: h(16)),
              OtpField(
                onChanged: (p0) {},
                enabled: false,
                initialString: invitationCode,
                isJoining: true,
                preFilledStar: true,
                onCompleted: (invitationCode) {},
              ),
              gap(height: h(18)),
              Row(
                spacing: w(16),
                children: [
                  Expanded(
                    child: SizedBox(
                      height: h(40),
                      child: OutlinedButton(
                        onPressed: () async {
                          context.pop();
                          // ignore: deprecated_member_use
                          await Share.share(
                            "Join Kitchen's Guardian using my referral code: $invitationCode",
                          );
                        },

                        child: Text(
                          "Share",
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                fontSize: t(12),
                                color: AppColors.primaryColor,
                              ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SizedBox(
                      height: h(40),
                      child: GenericButtonWidget(
                        onPressed: () {
                          context.pop();
                          Clipboard.setData(
                            ClipboardData(text: invitationCode),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.grey.shade100,
                              content: Text(
                                "Referral code copied to clipboard",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(color: Colors.black),
                              ),
                            ),
                          );
                        },
                        text: "Copy",
                      ),
                    ),
                  ),
                ],
              ),
              gap(height: 12),
            ],
          ),
        );
      },
    );
  }
}
