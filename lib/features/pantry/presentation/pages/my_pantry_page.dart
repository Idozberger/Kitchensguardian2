import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/custom_appbar.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/pantry_item_card.dart';

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

  void getPantryItems() {
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
                                    _buildItemList(
                                      context,
                                      requestButton: true,
                                      pantryLoaded: state,
                                    ),
                                    _buildItemList(
                                      context,
                                      pantryLoaded: state,
                                    ),
                                    _buildItemList(
                                      context,
                                      pantryLoaded: state,
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
        bottomNavigationBar: userCubit.state.role != "member"
            ? null
            : SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: gapSymmetric(horizontal: 20, vertical: 10),
                      child: UpperTile(
                        widget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Request List",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            SizedBox(height: h(10)),
                            Text(
                              "Request host to buy groceries or dinner",
                              style: Theme.of(context).textTheme.headlineMedium!
                                  .copyWith(
                                    fontSize: t(15),
                                    color: Color(0xff787878),
                                  ),
                            ),
                            SizedBox(height: h(20)),
                            GenericButtonWidget(
                              onPressed: () {},
                              text: "Request Now",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildItemList(
    BuildContext context, {
    bool requestButton = false,
    required PantryLoaded pantryLoaded,
  }) {
    return ListView.separated(
      itemCount: pantryLoaded.pantryItems.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xffF4F4F4)),
      padding: gapSymmetric(horizontal: 20, vertical: 20),
      itemBuilder: (_, index) {
        var pantry = pantryLoaded.pantryItems[index];
        return PantryItemCard(
          title: pantry.name,
          quantity: pantry.quantity.toString(),
          unit: pantry.unit,
          pantry: pantry.group,
          expiry: "Expires in ${index + 1} days",
        );
      },
    );
  }
}
