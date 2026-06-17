// ignore_for_file: prefer_final_fields

part of 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_body.dart';

extension _GroceryBodyLayout on _GroceryBodyState {
  Widget buildGroceryLoadingView() {
    return Center(child: Lottie.asset(AppAssets.loader));
  }

  Widget buildGrocerySearchBar() {
    return Padding(
      padding: gapSymmetric(
        horizontal: _GroceryBodyState._horizontalPadding,
        vertical: _GroceryBodyState._verticalPadding,
      ),
      child: SearchBarWidget(
        controller: widget.controller,
        onChanged: _updateSearchQuery,
      ),
    );
  }

  Widget buildGroceryCategoryTabs() {
    return CategoryTabs(
      categories: _GroceryBodyState._tabLabels,
      selectedIndex: _selectedTabIndex,
      onTabSelected: _updateSelectedTab,
    );
  }

  Widget? buildGroceryFloatingActionButton() {
    if (_selectedTabIndex != 2) {
      return null;
    }

    return FloatingActionButton(
      key: const Key(_GroceryBodyState._finalListKey),
      heroTag: _GroceryBodyState._finalListKey,
      tooltip: "Add Custom Items",
      backgroundColor: AppColors.primaryColor,
      shape: const CircleBorder(),
      onPressed: () => context.push(Routes.addCustomItem),
      child: const Icon(Icons.add, color: Colors.black),
    );
  }

  Widget buildGroceryListContent(GroceryState state) {
    final currentList = groceryBodyCurrentList(state);
    final filteredList = groceryBodyFilterList(currentList);

    return Padding(
      padding: gapSymmetric(
        horizontal: _GroceryBodyState._contentHorizontalPadding,
      ),
      child: filteredList.isEmpty
          ? buildGroceryEmptyStateView()
          : buildGroceryPopulatedListView(filteredList, state),
    );
  }

  List<RequestedItemEntity> groceryBodyCurrentList(GroceryState state) {
    return switch (_selectedTabIndex) {
      0 => state.requestedItemsList ?? [],
      1 => state.aiGeneratedList ?? [],
      2 => state.finalListItemsList ?? [],
      int() => [],
    };
  }

  List<RequestedItemEntity> groceryBodyFilterList(
    List<RequestedItemEntity> items,
  ) {
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

  Widget buildGroceryEmptyStateView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  gap(height: _GroceryBodyState._gapHeightLarge),
                  Image.asset(
                    AppAssets.groceryEmpty,
                    width: w(_GroceryBodyState._emptyStateImageWidth),
                  ),
                  gap(height: _GroceryBodyState._gapHeightSmall),
                  Text(
                    "Your grocery list is empty",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: _GroceryBodyState._emptyStateTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildGroceryPopulatedListView(
    List<RequestedItemEntity> filteredList,
    GroceryState state,
  ) {
    return Column(
      children: [
        Expanded(child: buildGroceryItemsList(filteredList)),
        gap(height: _GroceryBodyState._gapHeight),
        buildGroceryFooterWidget(state),
        SizedBox(height: h(_GroceryBodyState._gapHeightSmall)),
      ],
    );
  }

  Widget buildGroceryItemsList(List<RequestedItemEntity> items) {
    return UpperTile(
      horizontalPadding: 0,
      verticalPadding: _GroceryBodyState._tilePaddingVertical,
      widget: Scrollbar(
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
                  isChecked: groceryBodyIsItemChecked(item.itemId),
                  isFinalList: _selectedTabIndex == 2,
                  onChanged: (_) => _toggleItemSelection(item.itemId),
                  onDelete: () => groceryBodyHandleDeleteItem(item.itemId),
                  showDivider: index != items.length - 1,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGroceryFooterWidget(GroceryState state) {
    if (_selectedTabIndex == 2) {
      return FinalListFooter(
        isFinalListTabTriggered: true,
        groceryList: state.finalListItemsList ?? [],
        onRemoveCallback: () =>
            groceryBodyHandleDeleteAll(state.finalListItemsList ?? []),
        onAddToFinalListCallback: () {},
      );
    }

    return FinalListFooter(
      isFinalListTabTriggered: false,
      groceryList: state.requestedItemsList ?? [],
      onRemoveCallback: () {
        if (_selectedTabIndex == 1) {
          groceryBodyHandleDeleteAll(state.aiGeneratedList ?? []);
        } else {
          groceryBodyHandleDeleteAll(state.requestedItemsList ?? []);
        }
      },
      onAddToFinalListCallback: groceryBodyHandleAddToFinalList,
    );
  }

  bool groceryBodyIsItemChecked(String itemId) {
    if (_selectedTabIndex == 2) return _finalListSelectedItems.contains(itemId);
    return _requestedAndAiGeneratedSelectedList.contains(itemId);
  }

  void groceryBodyHandleDeleteItem(String itemId) {
    devLog("Grocery: $itemId");
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
              bucketType: _GroceryBodyState._bucketTypeRequested,
            ),
          );
        }
      },
    );
  }

  void groceryBodyHandleDeleteAll(List<RequestedItemEntity> itemList) {
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
              bucketType: _GroceryBodyState._bucketTypeRequested,
            ),
          );
        }
      },
    );
  }

  void groceryBodyHandleAddToFinalList() {
    if (_requestedAndAiGeneratedSelectedList.isEmpty) {
      AppToast.show("Please select at least one item", ToastType.error);
      return;
    }

    widget.groceryBloc.add(
      UpdateBucketTypeEvent(
        kitchenId: widget.userCubit.state.activeKitchenId,
        itemIds: _requestedAndAiGeneratedSelectedList,
        bucketType: _GroceryBodyState._bucketTypeFinalList,
      ),
    );
    _requestedAndAiGeneratedSelectedList = [];
  }
}
