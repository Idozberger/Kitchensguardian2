import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:go_router/go_router.dart';

class AllPantryStoragePage extends StatefulWidget {
  const AllPantryStoragePage({super.key});

  @override
  State<AllPantryStoragePage> createState() => _AllPantryStoragePageState();
}

class _AllPantryStoragePageState extends State<AllPantryStoragePage> {
  late PantryBloc pantryBloc;
  late UserCubit userCubit;

  @override
  void initState() {
    super.initState();
    pantryBloc = context.read<PantryBloc>();
    userCubit = context.read<UserCubit>();
    pantryBloc.add(
      GetUserStorageAreaForPantryViewEvent(userCubit.state.activeKitchenId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, userState) {
        return Scaffold(
          backgroundColor: const Color(0xffF9F9F9),
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: BlocConsumer<PantryBloc, PantryState>(
              listener: (_, state) {
                if (state is PantrySuccess) {
                  AppToast.show(state.successMessage, ToastType.success);
                  pantryBloc.add(
                    GetUserStorageAreaForPantryViewEvent(
                      userCubit.state.activeKitchenId,
                    ),
                  );
                }
                if (state is PantryFailure) {
                  AppToast.show(state.errorMessage, ToastType.error);
                }
              },
              builder: (_, state) {
                if (state is PantryLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (state is UserStorageAreaLoaded) {
                  if (userState.userStorageAreas.isEmpty) {
                    return _emptyState(context, userState);
                  }

                  return ListView.builder(
                    padding: gapSymmetric(horizontal: 20, vertical: 14),
                    itemCount: userState.userStorageAreas.length,
                    itemBuilder: (context, index) {
                      final storage = userState.userStorageAreas[index];
                      return Padding(
                        padding: gapOnly(bottom: 10),
                        child: UpperTile(
                          widget: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                storage.pantryName,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              CircularIconButton(
                                onTap: () {
                                  showCustomGenericDialog(
                                    context: context,
                                    title: "Delete Pantry",
                                    subtitle:
                                        "Are you sure you want to delete this pantry?",
                                    primaryButtonText: "Yes",
                                    secondaryButtonText: "Cancel",
                                    onPrimaryPressed: () {
                                      pantryBloc.add(
                                        DeletePantryEvent(
                                          kitchenId:
                                              userCubit.state.activeKitchenId,
                                          pantryId: storage.pantryId,
                                        ),
                                      );

                                      context.pop();
                                    },
                                    onSecondaryPressed: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                iconAsset: AppAssets.deleteSvg,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return _emptyState(context, state);
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniStartFloat,
          floatingActionButton: userState.userStorageAreas.isEmpty
              ? SizedBox()
              : FloatingActionButton(
                  heroTag: "add_new_storage_fab",
                  key: Key("get_all_storage"),
                  elevation: 4,
                  backgroundColor: AppColors.primaryColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    if (userState.role != "member") {
                      context.push(Routes.addPantryStorageType);
                    } else {
                      AppToast.show(
                        "Only host or co-host can add pantry storage",
                        ToastType.error,
                      );
                    }
                  },

                  child: SvgPicture.asset(
                    AppAssets.addSvg,
                    color: Colors.black,
                    height: h(16),
                  ),
                ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      centerTitle: true,
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
        "All Storage Areas",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _emptyState(BuildContext context, state) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey,
            ),
            gap(height: 16),
            Text(
              "No storage areas yet.",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(color: Colors.grey),
            ),
            gap(height: 12),
            GenericButtonWidget(
              text: "Add Storage Type",
              onPressed: () {
                if (state.role != "member") {
                  context.push(Routes.addPantryStorageType);
                } else {
                  AppToast.show(
                    "Only host or co-host can add pantry storage",
                    ToastType.error,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
