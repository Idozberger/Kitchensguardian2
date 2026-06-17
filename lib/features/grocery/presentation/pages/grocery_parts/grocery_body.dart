// ignore_for_file: prefer_final_fields
// Fields reassigned during list lifecycle; final would require larger refactor.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_list_item.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/category_tabs.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/final_list_footer.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/search_bar.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/show_delete_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

part 'grocery_body_part.dart';

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
  final ScrollController _itemsScrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroceryBloc, GroceryState>(
      builder: (_, state) {
        if (widget.state.isLoading) {
          return buildGroceryLoadingView();
        }

        return Scaffold(
          backgroundColor: _backgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildGrocerySearchBar(),
                buildGroceryCategoryTabs(),
                gap(height: _gapHeight),
                Expanded(child: buildGroceryListContent(state)),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniStartFloat,
          floatingActionButton: buildGroceryFloatingActionButton(),
        );
      },
    );
  }
}
