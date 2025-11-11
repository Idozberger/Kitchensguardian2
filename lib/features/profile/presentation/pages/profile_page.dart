import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_premium_card_widget.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_event.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_state.dart';
import 'package:foodkitchen/features/profile/presentation/widgets/header.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileBloc profileBloc;
  @override
  void initState() {
    profileBloc = context.read<ProfileBloc>();
    getProfilePicture();
    super.initState();
  }

  void getProfilePicture() {
    profileBloc.add(LoadProfilePicture());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (_, state) {
        return Scaffold(
          backgroundColor: const Color(0xffF9F9F9),
          body: state.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: gapOnly(left: 20, right: 20, top: 14, bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeader(profileState: state),
                        gap(height: 20),
                        PremiumCardWidget(isGoProButtonEnabled: true),
                        gap(height: 20),
                        UpperTile(
                          widget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Account Management",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
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
                                  AppToast.show(
                                    "Restore Purchases",
                                    ToastType.success,
                                  );
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
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
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
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                              gap(height: 10),

                              _buildListTile(
                                context,
                                assetPath: AppAssets.likeSvg,
                                title: "Tell a friend!",
                                subTitle: "",
                                callback: () {
                                  AppToast.show(
                                    "Tell a friend!",
                                    ToastType.success,
                                  );
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
      },
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
