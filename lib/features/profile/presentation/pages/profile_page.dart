import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_account_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
//import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
//import 'package:foodkitchen/core/widgets/generic_premium_card_widget.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_event.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_state.dart';
import 'package:foodkitchen/features/profile/presentation/widgets/header.dart';
//import 'package:foodkitchen/features/subscription/data/datasource/subscription_remote_datasource.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /*
  Future<void> _restoreSubscription(BuildContext context) async {
    try {
      final userCubit = context.read<UserCubit>();
      final result = await sl<SubscriptionRemoteDatasource>().restoreSubscription();
      if (!context.mounted) return;
      await userCubit.setUser();
      if (!context.mounted) return;
      final active = result['entitlement_is_active'] == true;
      AppToast.show(
        active
            ? 'Subscription restored.'
            : 'No active subscription found on your account.',
        active ? ToastType.success : ToastType.warning,
      );
    } on Object catch (e) {
      AppToast.show(e.toString(), ToastType.error);
    }
  }
*/

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
                        /*PremiumCardWidget(isGoProButtonEnabled: true),
                        gap(height: 20),*/
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
                                assetPath: AppAssets.deleteSvg,
                                title: "Delete Account",
                                subTitle: "Permanently delete your account",
                                callback: () {
                                  showDeleteAccountDialog(context);
                                },
                              ),
                              /*gap(height: 5),
                              _buildListTile(
                                context,
                                assetPath: AppAssets.restorePurchaseSvg,
                                title: "Restore Purchases",
                                subTitle: "",
                                callback: () {
                                  unawaited(_restoreSubscription(context));
                                },
                              ),*/
                            ],
                          ),
                        ),
                        gap(height: 20),
                        UpperTile(
                          widget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Smart Kitchen Management",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                              gap(height: 10),
                              _buildListTile(
                                context,
                                assetPath: AppAssets.reScanSvg,
                                title: "Rescan Kitchen",
                                subTitle:
                                    "Update your kitchen inventory with new photos",
                                callback: () {
                                  if (context.read<UserCubit>().state.role !=
                                      "member") {
                                    context.pushNamed(
                                      Routes.smartKitchenSetup,
                                      extra: true,
                                    );
                                  } else {
                                    AppToast.show(
                                      "Only the host or cohost can rescan the kitchen.",
                                      ToastType.warning,
                                    );
                                  }
                                },
                              ),
                              gap(height: 10),
                              const _UnitSystemSelector(),
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
                                  final String shareText =
                                      '''
Hey!

I’m loving com.itz.kitchens.guardian – the easiest way to plan weekly meals, create shopping lists automatically, and save time in the kitchen!

You should try it too – it’s free and super helpful for busy families.

Download here: https://play.google.com/store/apps/details?id=com.itz.kitchens.guardian

Happy cooking!

Shared with love from KitchenGuardian
'''
                                          .trim();

                                  unawaited(
                                    SharePlus.instance.share(
                                      ShareParams(text: shareText),
                                    ),
                                  );
                                },
                              ),
                              gap(height: 5),

                              _buildListTile(
                                context,
                                assetPath: AppAssets.starSvg,
                                title: "Rate app",
                                subTitle: "",
                                callback: () async {
                                  const String androidUrl =
                                      'https://play.google.com/store/apps/details?id=com.itz.kitchens.guardian';
                                  const String iosUrl =
                                      'https://apps.apple.com/app/idYOUR_APPLE_APP_ID';

                                  final Uri uri = Uri.parse(
                                    Platform.isAndroid ? androidUrl : iosUrl,
                                  );

                                  try {
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      AppToast.show(
                                        "Could not open store",
                                        ToastType.error,
                                      );
                                    }
                                  } catch (e) {
                                    AppToast.show(
                                      "Something went wrong",
                                      ToastType.error,
                                    );
                                  }
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

/// Measurement system (Metric / Imperial) for the active kitchen — BRD UC-04.
///
/// The backend gates `set_unit_system` to the host, so non-hosts see the
/// current value but get a toast instead of a write. Existing pantry, recipe
/// and grocery data needs no client conversion: storage stays metric and the
/// backend converts on the next read.
class _UnitSystemSelector extends StatefulWidget {
  const _UnitSystemSelector();

  @override
  State<_UnitSystemSelector> createState() => _UnitSystemSelectorState();
}

class _UnitSystemSelectorState extends State<_UnitSystemSelector> {
  bool _isSaving = false;

  Future<void> _onChanged(String? value) async {
    if (value == null || _isSaving) return;

    final userCubit = context.read<UserCubit>();
    if (userCubit.state.role != "host") {
      AppToast.show(
        "Only the host can change the measurement system.",
        ToastType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);
    final error = await userCubit.changeUnitSystemForActiveKitchen(
      unitSystemFromApi(value),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      AppToast.show(error, ToastType.error);
    } else {
      AppToast.show("Measurement system updated.", ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (previous, current) =>
          previous.unitSystem != current.unitSystem,
      builder: (context, state) => PopupDropdownField(
        label: "Measurement System",
        hint: "Select system",
        value: unitSystemToApi(state.unitSystem),
        items: unitSystemOptions,
        displayLabel: unitSystemDisplayLabel,
        onChanged: _onChanged,
      ),
    );
  }
}
