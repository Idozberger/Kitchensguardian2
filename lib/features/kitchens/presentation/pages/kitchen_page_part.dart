part of 'package:foodkitchen/features/kitchens/presentation/pages/kitchen_page.dart';

extension _KitchenPageLayout on _KitchenPageState {
  Widget buildKitchenPageBody(BuildContext context, KitchenState kitchenState) {
    if (kitchenState is KitchensLoading) {
      return Center(child: Lottie.asset(AppAssets.loader));
    }

    if (kitchenState is KitchensLoaded) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KitchenJoiningStatus(
                  userId: context.read<UserCubit>().state.userId,
                ),
                buildKitchenJoinedSection(context, kitchenState),
                SizedBox(height: h(20)),
                buildKitchenCreateSection(context),
                SizedBox(height: h(20)),
                buildKitchenOwnedSection(context, kitchenState),
              ],
            ),
          ),
        ),
      );
    }

    return EmptyUsersView(onRetry: _loadAllKitchens);
  }

  Widget buildKitchenJoinedSection(BuildContext context, KitchensLoaded state) {
    final joinedKitchens = state.kitchens
        .where((kitchen) => kitchen.role != "host")
        .toList();

    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen You Have Joined",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: h(15)),
          if (joinedKitchens.isEmpty)
            Text(
              "No Kitchen Found",
              style: Theme.of(context).textTheme.headlineMedium,
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: joinedKitchens.length,
              itemBuilder: (context, index) => buildKitchenTile(
                kitchenName: joinedKitchens[index].kitchenName,
                context: context,
                kitchen: joinedKitchens[index],
                isOwned: false,
              ),
            ),
          SizedBox(height: h(15)),
          GenericButtonWidget(
            onPressed: () => showJoinKitchenDialogForKitchen(context),
            text: "Join a Kitchen",
          ),
        ],
      ),
    );
  }

  Widget buildKitchenCreateSection(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create a kitchen",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: h(15)),
          SizedBox(
            width: double.infinity,
            height: h(40),
            child: OutlinedButton(
              onPressed: () => showCreateKitchenDialog(context),
              child: Text(
                "Create New",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

  Widget buildKitchenOwnedSection(BuildContext context, KitchensLoaded state) {
    final ownedKitchens = state.kitchens
        .where((kitchen) => kitchen.role.toLowerCase() == "host")
        .toList();

    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen you have",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: h(15)),
          Text(
            ownedKitchens.isNotEmpty
                ? "${ownedKitchens.length} kitchen found"
                : "No kitchen found",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: t(15)),
          ),
          SizedBox(height: h(14)),
          if (ownedKitchens.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ownedKitchens.length,
              itemBuilder: (context, index) => buildKitchenTile(
                kitchenName: ownedKitchens[index].kitchenName,
                context: context,
                kitchen: ownedKitchens[index],
                isOwned: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildKitchenTile({
    required BuildContext context,
    required Kitchen kitchen,
    required String kitchenName,
    required bool isOwned,
  }) {
    final isActive = _userCubit.state.activeKitchenId == kitchen.kitchenId;

    return Padding(
      padding: gapOnly(bottom: 4),
      child: KitchenTile(
        isMember: !isOwned,
        buttonText: isActive ? "Active" : "Show",
        onSecondaryActionTap: () =>
            handleKitchenSecondaryAction(context, kitchen, isOwned),
        onButtonPressed: isActive
            ? null
            : () => handleKitchenSwitch(context, kitchen, kitchenName),
        imagePath: AppAssets.avatar,
        title: kitchen.kitchenName,
        email: kitchen.invitationCode,
        membersText: "(${kitchen.role})",
      ),
    );
  }

  void handleKitchenSecondaryAction(
    BuildContext context,
    Kitchen kitchen,
    bool isOwned,
  ) {
    final title = isOwned ? "Delete Kitchen" : "Leave Kitchen";
    final subtitle = isOwned
        ? "Are you sure you want to delete this kitchen?"
        : "Are you sure you want to leave this kitchen?";

    showCustomGenericDialog(
      context: context,
      title: title,
      subtitle: subtitle,
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: () async {
        if (isOwned) {
          _kitchenBloc.add(RemoveKitchenEvent(kitchen.kitchenId));
        } else {
          _kitchenBloc.add(LeaveKitchenEvent(kitchen.kitchenId));
        }
        await _userCubit.updateStorageAreaToEmpty();
        if (context.mounted) context.pop();
      },
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  Future<void> handleKitchenSwitch(
    BuildContext context,
    Kitchen kitchen,
    String kitchenName,
  ) async {
    if (kitchen.kitchenId.isEmpty) {
      AppToast.show("Invalid kitchen ID", ToastType.error);
      return;
    }

    final router = GoRouter.of(context);
    final consumptionBloc = context.read<ConsumptionBloc>();

    final prefs = sl<SharedPreferences>();
    await prefs.setString("kitchen_id", kitchen.kitchenId);
    await prefs.setString("role", kitchen.role);
    await prefs.setString("invitation_code", kitchen.invitationCode);

    _userCubit.updateActiveKitchenIdInvitationCodeAndRole(
      kitchenName: kitchenName,
      activeKitchenId: kitchen.kitchenId,
      invitationCode: kitchen.invitationCode,
      role: kitchen.role,
    );

    AppToast.show(
      "Kitchen switched to ${kitchen.kitchenName}",
      ToastType.success,
    );

    _kitchenBloc.add(SwitchKitchenEvent(kitchen));

    consumptionBloc.add(
      GetConsumptionConfirmationPendingCountEvent(kitchenId: kitchen.kitchenId),
    );

    await _userCubit.getUserStorageArea(kitchenId: kitchen.kitchenId);

    if (_userCubit.state.userStorageAreas.isEmpty) {
      router.goNamed(Routes.smartKitchenSetup, extra: false);
    }
  }

  AppBar buildKitchenPageAppBar() {
    return AppBar(
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "Kitchen's",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
