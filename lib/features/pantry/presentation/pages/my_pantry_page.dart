// ignore_for_file: use_build_context_synchronously

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';

import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';

import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';

import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/custom_appbar.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/pantry_item_card.dart';
import 'package:go_router/go_router.dart';

class MyPantryPage extends StatefulWidget {
  const MyPantryPage({super.key});

  @override
  State<MyPantryPage> createState() => _MyPantryPageState();
}

class _MyPantryPageState extends State<MyPantryPage> {
  late UserCubit userCubit;
  late PantryBloc pantryBloc;
  @override
  void initState() {
    userCubit = context.read<UserCubit>();
    pantryBloc = context.read<PantryBloc>();
    getPantryItems();

    super.initState();
  }

  Future<void> requestExactAlarmPermission() async {
    await NotificationService().requestPermission();
  }

  void getPantryItems() async {
    bool hasPermission = await NotificationService().isExactAlarmAllowed();
    if (!hasPermission) {
      showCustomGenericDialog(
        context: context,
        title: "Exact Alarm Permission Needed",
        subtitle:
            "To schedule accurate notifications, please allow this permission.",
        primaryButtonText: "Allow",
        secondaryButtonText: "Cancel",
        onPrimaryPressed: () async {
          await requestExactAlarmPermission();
          context.pop();
        },
        onSecondaryPressed: () {
          context.pop();
        },
      );
    }

    final kitchenId = userCubit.state.activeKitchenId.trim();

    if (kitchenId.isEmpty) {
      AppToast.show(
        "Please join a kitchen before adding pantry items.",
        ToastType.warning,
      );
      return;
    }

    pantryBloc.add(GetPantryItemsEvent(kitchenId: kitchenId));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xffF9F9F9),
        appBar: buildAppBar(context),
        body: BlocConsumer<PantryBloc, PantryState>(
          listener: (_, state) {
            if (state is PantryFailure) {
              AppToast.show(state.errorMessage, ToastType.error);
            }
            if (state is PantrySuccess) {
              AppToast.show(state.successMessage, ToastType.success);
            }
          },
          builder: (_, state) {
            return SafeArea(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.primaryColor,
                            width: h(2),
                          ),
                        ),
                      ),
                      labelColor: AppColors.primaryColor,
                      unselectedLabelColor: const Color(0xff787878),
                      tabs: const [
                        Tab(text: "All Items"),
                        Tab(text: "Expiring"),
                        Tab(text: "Low Stock"),
                      ],
                    ),
                  ),

                  Expanded(
                    child: state is PantryLoaded
                        ? state.pantryItems.isEmpty
                              ? Center(
                                  child: Text(
                                    "No Items found",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                )
                              : TabBarView(
                                  children: [
                                    /// All Items
                                    _buildItemList(
                                      context,
                                      items: state.pantryItems,
                                    ),

                                    /// Expiring Soon
                                    _buildItemList(
                                      context,
                                      items: state.expiringItems,
                                    ),

                                    /// Low Stock
                                    _buildItemList(
                                      context,
                                      items: state.lowStockItems,
                                    ),
                                  ],
                                )
                        : Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemList(
    BuildContext context, {
    required List<PantryItemEntity> items,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No Items found",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xffF4F4F4)),
      padding: gapSymmetric(horizontal: 20, vertical: 20),
      itemBuilder: (_, index) {
        var pantry = items[index];
        return PantryItemCard(
          title: pantry.name,
          quantity: pantry.quantity.toString(),
          unit: pantry.unit,
          pantry: pantry.group,
          expiry: pantry.expireDate.isEmpty
              ? "Expire in 2 days"
              : pantry.expireDate,
          onListCheckedCallback: () async {},
          onCartItem: () async {
            pantryBloc.add(
              CartItemsEvent(
                pantry: Pantry(
                  kitchenId: userCubit.state.activeKitchenId,
                  items: [pantry],
                ),
                index: index,
              ),
            );
          },
          pantryItemEntity: pantry,
          kitchenId: userCubit.state.activeKitchenId,
        );
      },
    );
  }
}
