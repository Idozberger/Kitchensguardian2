import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';
import 'package:foodkitchen/features/kitchens/presentation/dialogs/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/dialogs/join_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  late final KitchenBloc _kitchenBloc;
  late final UserCubit _userCubit;

  @override
  void initState() {
    super.initState();
    _kitchenBloc = context.read<KitchenBloc>();
    _userCubit = context.read<UserCubit>();
    _loadAllKitchens();
  }

  void _loadAllKitchens() {
    _kitchenBloc.add(FetchKitchens());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      body: BlocConsumer<KitchenBloc, KitchenState>(
        listener: _handleStateChanges,
        builder: (context, kitchenState) => _buildBody(context, kitchenState),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, KitchenState state) {
    if (state is OpenKitchen || state is KitchenSuccess) {
      _loadAllKitchens();
      if (state is KitchenSuccess) {
        AppToast.show(state.successMessage, ToastType.success);
      }
    }
    if (state is KitchenFailure) {
      AppToast.show(state.errorMessage, ToastType.error);
      _loadAllKitchens();
    }
  }

  Widget _buildBody(BuildContext context, KitchenState kitchenState) {
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
                _buildJoinedKitchensSection(context, kitchenState),
                SizedBox(height: h(20)),
                _buildCreateKitchenSection(context),
                SizedBox(height: h(20)),
                _buildOwnedKitchensSection(context, kitchenState),
              ],
            ),
          ),
        ),
      );
    }

    return EmptyUsersView(onRetry: _loadAllKitchens);
  }

  Widget _buildJoinedKitchensSection(
    BuildContext context,
    KitchensLoaded state,
  ) {
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
              itemBuilder: (context, index) => _buildKitchenTile(
                context: context,
                kitchen: joinedKitchens[index],
                isOwned: false,
              ),
            ),
          SizedBox(height: h(15)),
          GenericButtonWidget(
            onPressed: () => showJoinKitchenDialog(context),
            text: "Join a Kitchen",
          ),
        ],
      ),
    );
  }

  Widget _buildCreateKitchenSection(BuildContext context) {
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

  Widget _buildOwnedKitchensSection(
    BuildContext context,
    KitchensLoaded state,
  ) {
    final ownedKitchens = state.kitchens
        .where((kitchen) => kitchen.role.toLowerCase() != "member")
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
              itemBuilder: (context, index) => _buildKitchenTile(
                context: context,
                kitchen: ownedKitchens[index],
                isOwned: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKitchenTile({
    required BuildContext context,
    required dynamic kitchen,
    required bool isOwned,
  }) {
    final isActive = _userCubit.state.activeKitchenId == kitchen.kitchenId;

    return Padding(
      padding: gapOnly(bottom: 4),
      child: KitchenTile(
        isMember: !isOwned,
        buttonText: isActive ? "Active" : "Show",
        onSecondaryActionTap: () =>
            _handleSecondaryAction(context, kitchen, isOwned),
        onButtonPressed: isActive
            ? null
            : () => _handleKitchenSwitch(context, kitchen),
        imagePath: AppAssets.avatar,
        title: kitchen.kitchenName,
        email: kitchen.invitationCode,
        membersText: "(${kitchen.role})",
      ),
    );
  }

  void _handleSecondaryAction(
    BuildContext context,
    dynamic kitchen,
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

  Future<void> _handleKitchenSwitch(
    BuildContext context,
    dynamic kitchen,
  ) async {
    if (kitchen.kitchenId.isEmpty) {
      AppToast.show("Invalid kitchen ID", ToastType.error);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("kitchen_id", kitchen.kitchenId);
    await prefs.setString("role", kitchen.role);
    await prefs.setString("invitation_code", kitchen.invitationCode);

    _userCubit.updateActiveKitchenIdInvitationCodeAndRole(
      activeKitchenId: kitchen.kitchenId,
      invitationCode: kitchen.invitationCode,
      role: kitchen.role,
    );

    AppToast.show(
      "Kitchen switched to ${kitchen.kitchenName}",
      ToastType.success,
    );

    _kitchenBloc.add(SwitchKitchenEvent(kitchen));

    if (context.mounted) {
      context.read<DashboardBloc>().add(
        GetConsumptionConfirmationPendingCountEvent(
          kitchenId: kitchen.kitchenId,
        ),
      );
    }

    await _userCubit.getUserStorageArea(kitchenId: kitchen.kitchenId);
  }

  AppBar _buildAppBar() {
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

class EmptyUsersView extends StatelessWidget {
  final VoidCallback onRetry;

  const EmptyUsersView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 20, vertical: 14),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Something went wrong",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(
                "Try Again",
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
