// ignore_for_file: prefer_final_fields

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_list_item.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/category_tabs.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/final_list_footer.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/search_bar.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/show_delete_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class GroceryBody extends StatefulWidget {
  final GroceryState state;
  final UserCubit userCubit;
  final GroceryBloc groceryBloc;
  final TextEditingController controller;

  const GroceryBody({
    super.key,
    required this.state,
    required this.userCubit,
    required this.groceryBloc,
    required this.controller,
  });

  @override
  State<GroceryBody> createState() => _GroceryBodyState();
}

class _GroceryBodyState extends State<GroceryBody> {
  static const Color _backgroundColor = Color(0xffF9F9F9);
  static const Color _emptyStateTextColor = Color(0xffC3C3C3);
  static const double _horizontalPadding = 20;
  static const double _verticalPadding = 16;
  static const double _contentHorizontalPadding = 16;
  static const double _gapHeight = 16;
  static const double _gapHeightSmall = 12;
  static const double _gapHeightLarge = 164;
  static const double _emptyStateImageWidth = 112;
  static const double _tilePaddingVertical = 8;
  static const String _finalListKey = "final_list";
  static const String _bucketTypeFinalList = "mylist";
  static const String _bucketTypeRequested = "requested";
  static const List<String> _tabLabels = [
    "Requested Items",
    "AI Generated List",
    "Final List",
  ];

  List<String> _requestedAndAiGeneratedSelectedList = [];
  List<String> _finalListSelectedItems = [];
  int _selectedTabIndex = 0;
  String _searchQuery = "";

  void _updateSelectedTab(int index) {
    setState(() {
      _selectedTabIndex = index;
      _searchQuery = "";
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroceryBloc, GroceryState>(
      builder: (_, state) {
        if (widget.state.isLoading) {
          return _buildLoadingView();
        }

        return Scaffold(
          backgroundColor: _backgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildCategoryTabs(),
                gap(height: _gapHeight),
                _buildListContent(state),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniStartFloat,
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return Center(child: Lottie.asset(AppAssets.loader));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: gapSymmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: SearchBarWidget(
        controller: widget.controller,
        onChanged: _updateSearchQuery,
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return CategoryTabs(
      categories: _tabLabels,
      selectedIndex: _selectedTabIndex,
      onTabSelected: _updateSelectedTab,
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedTabIndex != 2) {
      return null;
    }

    return FloatingActionButton(
      key: const Key(_finalListKey),
      heroTag: _finalListKey,
      tooltip: "Add Custom Items",
      backgroundColor: AppColors.primaryColor,
      shape: const CircleBorder(),
      onPressed: () => context.push(Routes.addCustomItem),
      child: const Icon(Icons.add, color: Colors.black),
    );
  }

  Widget _buildListContent(GroceryState state) {
    final currentList = _getCurrentList(state);
    final filteredList = _filterList(currentList);

    return Padding(
      padding: gapSymmetric(horizontal: _contentHorizontalPadding),
      child: filteredList.isEmpty
          ? _buildEmptyStateView()
          : _buildPopulatedListView(filteredList, state),
    );
  }

  List<RequestedItemEntity> _getCurrentList(GroceryState state) {
    return switch (_selectedTabIndex) {
      0 => state.requestedItemsList ?? [],
      1 => state.aiGeneratedList ?? [],
      2 => state.finalListItemsList ?? [],
      int() => [],
    };
  }

  List<RequestedItemEntity> _filterList(List<RequestedItemEntity> items) {
    if (_searchQuery.isEmpty) {
      return items;
    }

    return items
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Widget _buildEmptyStateView() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          gap(height: _gapHeightLarge),
          Image.asset(AppAssets.groceryEmpty, width: w(_emptyStateImageWidth)),
          gap(height: _gapHeightSmall),
          Text(
            "Your grocery list is empty",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(color: _emptyStateTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPopulatedListView(
    List<RequestedItemEntity> filteredList,
    GroceryState state,
  ) {
    return Column(
      children: [
        _buildItemsList(filteredList),
        gap(height: _gapHeight),
        _buildFooterWidget(state),
        SizedBox(height: h(_gapHeightSmall)),
      ],
    );
  }

  final ScrollController _itemsScrollController = ScrollController();

  Widget _buildItemsList(List<RequestedItemEntity> items) {
    return UpperTile(
      horizontalPadding: 0,
      verticalPadding: _tilePaddingVertical,
      widget: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: h(408)),
        child: Scrollbar(
          controller: _itemsScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _itemsScrollController,
            child: Padding(
              padding: gapSymmetric(horizontal: 15),
              child: Column(
                children: List.generate(items.length, (index) {
                  final item = items[index];

                  return GroceryListItem(
                    grocery: item,
                    isChecked: _isItemChecked(item.itemId),
                    isFinalList: _selectedTabIndex == 2,
                    onChanged: (_) => _toggleItemSelection(item.itemId),
                    onDelete: () => _handleDeleteItem(item.itemId),
                    showDivider: index != items.length - 1,
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterWidget(GroceryState state) {
    if (_selectedTabIndex == 2) {
      return FinalListFooter(
        isFinalListTabTriggered: true,
        groceryList: state.finalListItemsList ?? [],
        onRemoveCallback: () =>
            _handleDeleteAll(state.finalListItemsList ?? []),
        onAddToFinalListCallback: () {},
      );
    }

    return FinalListFooter(
      isFinalListTabTriggered: false,
      groceryList: state.requestedItemsList ?? [],
      onRemoveCallback: () {
        _handleDeleteAll(state.requestedItemsList ?? []);
      },
      onAddToFinalListCallback: _handleAddToFinalList,
    );
  }

  bool _isItemChecked(String itemId) {
    if (_selectedTabIndex == 2) return _finalListSelectedItems.contains(itemId);
    return _requestedAndAiGeneratedSelectedList.contains(itemId);
  }

  void _toggleItemSelection(String itemId) {
    final selectedList = _selectedTabIndex == 2
        ? _finalListSelectedItems
        : _requestedAndAiGeneratedSelectedList;

    if (selectedList.contains(itemId)) {
      selectedList.remove(itemId);
    } else {
      selectedList.add(itemId);
    }

    setState(() {});
  }

  void _handleDeleteItem(String itemId) {
    log("Grocery: $itemId");
    showDialogForItemDeletion(
      context,
      callback: () {
        if (_selectedTabIndex != 2) {
          widget.groceryBloc.add(
            DeleteKitchenItemsEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: [itemId],
            ),
          );
        } else {
          widget.groceryBloc.add(
            UpdateBucketTypeEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: [itemId],
              bucketType: _bucketTypeRequested,
            ),
          );
        }
      },
    );
  }

  void _handleDeleteAll(List<RequestedItemEntity> itemList) {
    showDialogForItemDeletion(
      context,
      callback: () {
        final itemIds = itemList.map((item) => item.itemId).toList();

        if (_selectedTabIndex != 2) {
          widget.groceryBloc.add(
            DeleteKitchenItemsEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: itemIds,
            ),
          );
        } else {
          widget.groceryBloc.add(
            UpdateBucketTypeEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: itemIds,
              bucketType: _bucketTypeRequested,
            ),
          );
        }
      },
    );
  }

  void _handleAddToFinalList() {
    if (_requestedAndAiGeneratedSelectedList.isEmpty) {
      AppToast.show("Please select at least one item", ToastType.error);
      return;
    }

    widget.groceryBloc.add(
      UpdateBucketTypeEvent(
        kitchenId: widget.userCubit.state.activeKitchenId,
        itemIds: _requestedAndAiGeneratedSelectedList,
        bucketType: _bucketTypeFinalList,
      ),
    );
    _requestedAndAiGeneratedSelectedList = [];
  }
}
