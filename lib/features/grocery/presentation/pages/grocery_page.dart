import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_checktile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/category_tabs.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/final_list_footer.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/search_bar.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key});

  @override
  State<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  late final UserCubit userCubit;
  late final GroceryBloc groceryBloc;

  final TextEditingController _searchController = TextEditingController();
  final List<String> itemIds = [];
  final List<String> finalListItems = [];

  final List<String> _categories = [
    "Requested Items",
    "AI Generated List",
    "Final List",
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    userCubit = context.read<UserCubit>();
    groceryBloc = context.read<GroceryBloc>();
    _searchController.addListener(() => setState(() {}));
    _fetchRequestedItems();
  }

  void _fetchRequestedItems() async {
    final kitchenId = userCubit.state.activeKitchenId;
    if (kitchenId.isNotEmpty) {
      groceryBloc.add(RequestedGroceryEvent(kitchenId: kitchenId));

      groceryBloc.add(GetAiGeneratedItemsEvent(kitchenId: kitchenId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroceryBloc, GroceryState>(
      listener: _handleBlocListener,
      builder: _buildMainUI,
    );
  }

  void _handleBlocListener(BuildContext context, GroceryState state) {
    if (state.errorMessage != null) {
      AppToast.show(state.errorMessage!, ToastType.error);
    }

    if (state.successMessage != null) {
      setState(() => _selectedIndex = 2);
      AppToast.show(state.successMessage!, ToastType.success);
    }
  }

  Widget _buildMainUI(BuildContext context, GroceryState state) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarWidget(controller: _searchController),
                gap(height: 15),
                CategoryTabs(
                  categories: _categories,
                  selectedIndex: _selectedIndex,
                  onTabSelected: (index) {
                    _selectedIndex = index;
                    setState(() {});
                  },
                ),
                gap(height: 16),
                _buildCategoryContent(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent(GroceryState state) {
    if (state.isLoading) {
      return Padding(
        padding: gapOnly(top: 200),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    final currentList = switch (_selectedIndex) {
      0 => state.requestedItemsList,
      1 => state.aiGeneratedList,
      _ => state.finalListItemsList,
    };

    final query = _searchController.text.toLowerCase();
    final filteredList = currentList
        ?.where((item) => item.name.toLowerCase().contains(query))
        .toList();

    if (filteredList == null || filteredList.isEmpty) {
      return Padding(
        padding: gapOnly(top: 120),
        child: EmptyStateWidget(
          context,
          imagePath: AppAssets.groceryEmpty,
          title: 'No items found',
        ),
      );
    }

    return Column(
      children: [
        if (_selectedIndex == 2)
          GenericButtonWidget(
            onPressed: () {
              groceryBloc.add(
                AddMylistToInventoryEvent(
                  kitchenId: userCubit.state.activeKitchenId,
                ),
              );
            },
            text: "+ Add Costume Items",
          ),
        gap(height: 14),
        UpperTile(
          widget: Column(
            children: List.generate(currentList!.length, (index) {
              final grocery = currentList[index];
              return Column(
                children: [
                  GenericCircleCheckboxTile(
                    deleteCallback: () {
                      if (itemIds.contains(grocery.itemId)) {
                        _showDeleteDialog(context, grocery.itemId);
                      } else {
                        AppToast.show("Select item to delete", ToastType.error);
                      }
                    },
                    isFinalList: _selectedIndex == 2,
                    title: grocery.name,
                    isChecked: _selectedIndex != 2
                        ? itemIds.contains(grocery.itemId)
                        : finalListItems.contains(grocery.itemId),
                    contentPadding: gapAll(6),
                    activeColor: AppColors.primaryColor,
                    onChanged: (Object? value) {
                      if (_selectedIndex != 2) {
                        if (itemIds.contains(grocery.itemId)) {
                          itemIds.remove(grocery.itemId);
                        } else {
                          itemIds.add(grocery.itemId);
                        }
                      } else {
                        if (finalListItems.contains(grocery.itemId)) {
                          finalListItems.remove(grocery.itemId);
                        } else {
                          finalListItems.add(grocery.itemId);
                        }
                      }
                      setState(() {});
                    },
                  ),
                  if (index != currentList.length - 1)
                    const Divider(color: Color(0xffF4F4F4)),
                ],
              );
            }),
          ),
        ),

        gap(height: 20),
        if (userCubit.state.role != "member") _buildFooter(state),
      ],
    );
  }

  Widget _buildFooter(GroceryState state) {
    if (_selectedIndex != 2) {
      return AddToFinalListButton(
        hasItems: state.requestedItemsList?.isNotEmpty ?? false,
        itemIds: itemIds,
        onPressed: () {
          if (itemIds.isNotEmpty) {
            groceryBloc.add(
              UpdateBucketTypeEvent(
                kitchenId: userCubit.state.activeKitchenId,
                itemIds: itemIds,
                bucketType: "mylist",
              ),
            );
            finalListItems.clear();
            finalListItems.addAll(itemIds);
          } else {
            AppToast.show(
              "Please select at least one item before updating the bucket type.",
              ToastType.error,
            );
          }
        },
      );
    }

    return FinalListFooter(
      shareString: state.finalListItemsList.toString(),

      totalItems: state.finalListItemsList?.length ?? 0,
      completedItems: finalListItems.length,
    );
  }

  Future<dynamic> _showDeleteDialog(BuildContext context, String itemId) {
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
              Text(
                "Remove Item",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(14),
                ),
              ),
              SizedBox(height: h(10)),
              Text(
                "Are you sure you want to delete this item?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(12),
                  color: Color(0xff7B7B7B),
                ),
              ),
              SizedBox(height: h(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SizedBox(
                      height: h(40),
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          groceryBloc.add(
                            DeleteKitchenItemsEvent(
                              kitchenId: userCubit.state.activeKitchenId,
                              itemIds: [itemId],
                            ),
                          );
                          Navigator.pop(context);
                        },

                        child: Text(
                          "Yes",
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                fontSize: t(12),
                                color: AppColors.primaryColor,
                              ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: h(10)),
                  Flexible(
                    child: GenericButtonWidget(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      text: "Cancel",
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddToFinalListButton extends StatelessWidget {
  final bool hasItems;
  final List<String> itemIds;
  final VoidCallback onPressed;

  const AddToFinalListButton({
    super.key,
    required this.hasItems,
    required this.itemIds,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasItems) return const SizedBox.shrink();
    return GenericButtonWidget(text: "Add to Final List", onPressed: onPressed);
  }
}
