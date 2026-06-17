part of 'package:foodkitchen/features/dashboard/presentation/widgets/drawer_view.dart';

Widget _appDrawerProfileSection(BuildContext context) {
  return BlocBuilder<UserCubit, UserState>(
    builder: (_, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeCircleAvatar(
            radius: h(35),
            memoryBytes: state.profilePictureFilePath,
            fallback: Image.asset(
              AppAssets.avatar,
              fit: BoxFit.cover,
            ),
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

Widget _appDrawerItems(BuildContext context) {
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
                      devPrint("inivitaion code ${state.invitationCode}");
                      _appDrawerShowReferralCodeDialog(
                        context,
                        state.invitationCode,
                      );
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
                  if (context.read<UserCubit>().state.role != "member") {
                    context.pushNamed(Routes.smartKitchenSetup, extra: true);
                  } else {
                    AppToast.show(
                      "Only the host or cohost can rescan the kitchen.",
                      ToastType.warning,
                    );
                  }
                },
              ),

              Divider(color: Color(0xffF4F4F4)),
              DrawerListTile(
                title: "Recipe Start Requests",
                iconPath: AppAssets.requestsRecipes,
                onTap: () {
                  context.push(Routes.recipeStartRequests);
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
              Divider(color: Color(0xffF4F4F4)),
              DrawerListTile(
                title: "Delete Account",
                iconPath: AppAssets.deleteSvg,
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  showDeleteAccountDialog(context);
                },
              ),
              if (!kReleaseMode) ...[
                Divider(color: Color(0xffF4F4F4)),
                ListTile(
                  dense: true,
                  contentPadding: gapZero,
                  visualDensity: VisualDensity(vertical: -1),
                  leading: Icon(Icons.bug_report_outlined, size: t(24)),
                  title: Text(
                    'Test Crashlytics crash (dev)',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontSize: t(15),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'App will close. Check Firebase in a few minutes.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xff787878),
                    ),
                  ),
                  onTap: () async {
                    final go = await showDialog<bool>(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text('Send test crash?'),
                          content: const Text(
                            'The app will close immediately. After it restarts, '
                            'open the Firebase Crashlytics console — a new crash '
                            'may take a minute or two to appear.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Crash'),
                            ),
                          ],
                        );
                      },
                    );
                    if (go == true && context.mounted) {
                      Navigator.pop(context);
                      await AppLogger.triggerTestCrashForVerification();
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

Widget _appDrawerLogoutButton(BuildContext context) {
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

Future<dynamic> _appDrawerShowReferralCodeDialog(
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
                        await SharePlus.instance.share(
                          ShareParams(
                            text:
                                "Join Kitchen's Guardian using my referral code: $invitationCode",
                          ),
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
                        Clipboard.setData(ClipboardData(text: invitationCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.grey.shade100,
                            content: Text(
                              "Referral code copied to clipboard",
                              style: Theme.of(context).textTheme.headlineMedium!
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
