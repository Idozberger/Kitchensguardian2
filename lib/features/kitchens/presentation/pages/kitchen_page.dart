import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';
import 'package:foodkitchen/features/kitchens/presentation/dialogs/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/dialogs/join_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  late KitchenBloc kitchenBloc;
  late UserCubit userCubit;
  @override
  void initState() {
    kitchenBloc = context.read<KitchenBloc>();
    userCubit = context.read<UserCubit>();
    fetchAllKitchens();
    super.initState();
  }

  void fetchAllKitchens() {
    kitchenBloc.add(FetchKitchens());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocConsumer<KitchenBloc, KitchenState>(
        listener: (_, state) {
          if (state is KitchenSuccess) {
            AppToast.show(state.successMessage, ToastType.success);
            fetchAllKitchens();
          }
          if (state is KitchenFailure) {
            AppToast.show(state.errorMessage, ToastType.error);
          }
        },
        builder: (_, kitchenState) {
          if (kitchenState is KitchensLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          } else if (kitchenState is KitchensLoaded) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: gapSymmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, kitchenState),
                      SizedBox(height: h(20)),
                      _buildCreateKitchenTile(context),
                      SizedBox(height: h(20)),
                      _buildKitchenHaveSection(context, kitchenState),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
            child: Column(
              children: [
                Text("Something went wrong! "),
                TextButton(
                  onPressed: () {
                    fetchAllKitchens();
                  },
                  child: Text("Try again"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      title: Text(
        "Kitchen’s",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, KitchensLoaded kitchenState) {
    final kitchensWithoutInvitationCode = kitchenState.kitchens
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

          if (kitchensWithoutInvitationCode.isEmpty)
            Text(
              "No Kitchen Found",
              style: Theme.of(context).textTheme.headlineMedium!,
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kitchensWithoutInvitationCode.length,
              itemBuilder: (BuildContext context, int index) {
                final kitchen = kitchensWithoutInvitationCode[index];
                final isActive =
                    userCubit.state.activeKitchenId == kitchen.kitchenId;
                return Padding(
                  padding: gapOnly(bottom: 4),
                  child: KitchenTile(
                    isMember: true,
                    buttonText: isActive ? "Active" : "Show",
                    onSecondaryActionTap: () {
                      showCustomGenericDialog(
                        context: context,
                        title: "Leave Kitchen",
                        subtitle:
                            "Are you sure you want to leave this kitchen?",
                        primaryButtonText: "Yes",
                        secondaryButtonText: "Cancel",
                        onPrimaryPressed: () {
                          context.read<KitchenBloc>().add(
                            LeaveKitchenEvent(kitchen.kitchenId),
                          );

                          context.pop();
                        },
                        onSecondaryPressed: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                    onButtonPressed: isActive
                        ? () {}
                        : () async {
                            if (kitchen.kitchenId.isEmpty) {
                              AppToast.show(
                                "Invalid kitchen ID",
                                ToastType.error,
                              );
                              return;
                            }

                            final prefs = await SharedPreferences.getInstance();

                            await prefs.setString(
                              "kitchen_id",
                              kitchen.kitchenId,
                            );
                            await prefs.setString("role", kitchen.role);

                            userCubit
                                .updateActiveKitchenIdInvitationCodeAndRole(
                                  activeKitchenId: kitchen.kitchenId,
                                  invitationCode: kitchen.invitationCode,
                                  role: kitchen.role,
                                );

                            AppToast.show(
                              "Kitchen switched to ${kitchen.kitchenName}",
                              ToastType.success,
                            );

                            kitchenBloc.add(
                              SwitchKitchenEvent(kitchen.kitchenId),
                            );
                          },
                    imagePath: AppAssets.avatar,
                    title: kitchen.kitchenName,
                    email: kitchen.invitationCode,
                    membersText: "(${kitchen.role})",
                  ),
                );
              },
            ),

          SizedBox(height: h(15)),

          GenericButtonWidget(
            onPressed: () {
              showJoinKitchenDialog(context);
            },
            text: "Join a Kitchen",
          ),
        ],
      ),
    );
  }

  Widget _buildCreateKitchenTile(BuildContext context) {
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
              onPressed: () {
                showCreateKitchenDialog(context);
              },

              child: Text(
                "Create New",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
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

  Widget _buildKitchenHaveSection(
    BuildContext context,
    KitchensLoaded kitchenState,
  ) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen you have:",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: h(15)),

          Text(
            kitchenState.kitchens.isNotEmpty
                ? "${kitchenState.kitchens.length} kitchen found: "
                : "No kitchen found:",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: t(15)),
          ),
          SizedBox(height: h(14)),
          if (kitchenState.kitchens.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: kitchenState.kitchens.length,
              itemBuilder: (BuildContext _, int index) {
                final kitchen = kitchenState.kitchens[index];
                final isActive =
                    userCubit.state.activeKitchenId == kitchen.kitchenId;
                return Padding(
                  padding: gapOnly(bottom: 4),
                  child: KitchenTile(
                    isMember: false,
                    buttonText: isActive ? "Active" : "Show",
                    onSecondaryActionTap: () {
                      showCustomGenericDialog(
                        context: context,
                        title: "Delete Kitchen",
                        subtitle:
                            "Are you sure you want to delete this kitchen?",
                        primaryButtonText: "Yes",
                        secondaryButtonText: "Cancel",
                        onPrimaryPressed: () {
                          context.read<KitchenBloc>().add(
                            RemoveKitchenEvent(kitchen.kitchenId),
                          );

                          context.pop();
                        },
                        onSecondaryPressed: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                    onButtonPressed: isActive
                        ? () {}
                        : () async {
                            if (kitchen.kitchenId.isEmpty) {
                              AppToast.show(
                                "Invalid kitchen ID",
                                ToastType.error,
                              );
                              return;
                            }
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                              "kitchen_id",
                              kitchen.kitchenId,
                            );
                            await prefs.setString("role", kitchen.role);
                            userCubit
                                .updateActiveKitchenIdInvitationCodeAndRole(
                                  activeKitchenId: kitchen.kitchenId,
                                  invitationCode: kitchen.invitationCode,
                                  role: kitchen.role,
                                );
                            AppToast.show(
                              "Kitchen switched to ${kitchen.kitchenName}",
                              ToastType.success,
                            );
                            kitchenBloc.add(
                              SwitchKitchenEvent(kitchen.kitchenId),
                            );
                          },
                    imagePath: AppAssets.avatar,
                    title: kitchen.kitchenName,
                    email: kitchen.invitationCode,
                    membersText: "(${kitchen.role})",
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
