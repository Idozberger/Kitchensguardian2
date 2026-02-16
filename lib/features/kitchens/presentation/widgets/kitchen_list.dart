import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KitchenList extends StatelessWidget {
  final List<Kitchen> kitchens;
  final UserCubit userCubit;
  final KitchenBloc kitchenBloc;
  final bool isMember;

  const KitchenList({
    super.key,
    required this.kitchens,
    required this.userCubit,
    required this.kitchenBloc,
    required this.isMember,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: kitchens.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        final kitchen = kitchens[index];
        final isActive = userCubit.state.activeKitchenId == kitchen.kitchenId;

        return Padding(
          padding: gapOnly(bottom: 4),
          child: KitchenTile(
            isMember: isMember,
            buttonText: isActive ? "Active" : "Show",
            imagePath: AppAssets.avatar,
            title: kitchen.kitchenName,
            email: kitchen.invitationCode,
            membersText: "(${kitchen.role})",
            onSecondaryActionTap: () =>
                _onDeleteOrLeave(context, kitchen, isMember, kitchenBloc),
            onButtonPressed: () => isActive
                ? null
                : _onSwitch(context, kitchen, userCubit, kitchenBloc),
          ),
        );
      },
    );
  }

  void _onDeleteOrLeave(
    BuildContext context,
    kitchen,
    bool isMember,
    KitchenBloc bloc,
  ) {
    showCustomGenericDialog(
      context: context,
      title: isMember ? "Leave Kitchen" : "Delete Kitchen",
      subtitle: isMember
          ? "Are you sure you want to leave this kitchen?"
          : "Are you sure you want to delete this kitchen?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: () {
        bloc.add(
          isMember
              ? LeaveKitchenEvent(kitchen.kitchenId)
              : RemoveKitchenEvent(kitchen.kitchenId),
        );
        Navigator.pop(context);
      },
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  Future<void> _onSwitch(
    BuildContext context,
    Kitchen kitchen,
    UserCubit userCubit,
    KitchenBloc kitchenBloc,
  ) async {
    if (kitchen.kitchenId.isEmpty) {
      AppToast.show("Invalid kitchen ID", ToastType.error);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("kitchen_id", kitchen.kitchenId);
    await prefs.setString("role", kitchen.role);
    await prefs.setString("invitation_code", kitchen.invitationCode);

    userCubit.updateActiveKitchenIdInvitationCodeAndRole(
      kitchenName: kitchen.kitchenName,
      activeKitchenId: kitchen.kitchenId,
      invitationCode: kitchen.invitationCode,
      role: kitchen.role,
    );
    kitchenBloc.add(SwitchKitchenEvent(kitchen));
    await userCubit.getUserStorageArea(kitchenId: kitchen.kitchenId);

    AppToast.show("Kitchen opened: ${kitchen.kitchenName}", ToastType.success);
  }
}
