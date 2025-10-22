import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_footer.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_list_view.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/category_tabs.dart';

import 'package:foodkitchen/features/grocery/presentation/widgets/search_bar.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:go_router/go_router.dart';

enum GroceryCategory { requested, aiGenerated, finalList }

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
  GroceryCategory _selectedCategory = GroceryCategory.requested;
  final List<String> itemIds = [];
  final List<String> finalListItems = [];

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: gapSymmetric(horizontal: 20, vertical: 16),
                child: SearchBarWidget(controller: widget.controller),
              ),

              CategoryTabs(
                categories: const [
                  "Requested Items",
                  "AI Generated List",
                  "Final List",
                ],
                selectedIndex: _selectedCategory.index,
                onTabSelected: (index) {
                  _selectedCategory = GroceryCategory.values[index];
                  setState(() {});
                },
              ),
              Padding(
                padding: gapSymmetric(horizontal: 20, vertical: 16),
                child: GroceryListView(
                  state: state,
                  selectedCategory: _selectedCategory,
                  searchController: widget.controller,
                  itemIds: itemIds,
                  finalListItems: finalListItems,
                  userCubit: widget.userCubit,
                  groceryBloc: widget.groceryBloc,
                ),
              ),
              if (state.isLoading == false) getWidgetTile(state),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedCategory == GroceryCategory.finalList
          ? FloatingActionButton(
              key: Key("final_list"),
              heroTag: "final_list",
              tooltip: "Add Custom Items",
              backgroundColor: AppColors.primaryColor,
              shape: const CircleBorder(),
              onPressed: () => context.push(Routes.addCustomItem),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  Widget getWidgetTile(GroceryState state) {
    if (widget.userCubit.state.role != "member") {
      switch (_selectedCategory) {
        case GroceryCategory.requested:
          if (state.requestedItemsList != null &&
              state.requestedItemsList!.isNotEmpty) {
            return Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 0),
              child: GroceryFooter(
                selectedCategory: _selectedCategory,
                state: state,
                itemIds: itemIds,
                finalListItems: finalListItems,
                groceryBloc: widget.groceryBloc,
                userCubit: widget.userCubit,
              ),
            );
          }
          return const SizedBox.shrink();

        case GroceryCategory.aiGenerated:
          if (state.aiGeneratedList != null &&
              state.aiGeneratedList!.isNotEmpty) {
            return Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 0),
              child: GroceryFooter(
                selectedCategory: _selectedCategory,
                state: state,
                itemIds: itemIds,
                finalListItems: finalListItems,
                groceryBloc: widget.groceryBloc,
                userCubit: widget.userCubit,
              ),
            );
          }
          return const SizedBox.shrink();

        case GroceryCategory.finalList:
          if (state.finalListItemsList != null &&
              state.finalListItemsList!.isNotEmpty) {
            return Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 0),
              child: GroceryFooter(
                selectedCategory: _selectedCategory,
                state: state,
                itemIds: itemIds,
                finalListItems: finalListItems,
                groceryBloc: widget.groceryBloc,
                userCubit: widget.userCubit,
              ),
            );
          }
          return const SizedBox.shrink();
      }
    }
    return SizedBox();
  }
}
