// ignore_for_file: unnecessary_underscores
// Legacy private field names in this page; rename when refactoring pantry UI.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/my_pantry/my_pantry_filter_sheet.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/my_pantry/my_pantry_item_list.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/custom_appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class MyPantryPage extends StatefulWidget {
  final String itemId;
  final String type;
  const MyPantryPage({super.key, this.itemId = "", this.type = ""});

  @override
  State<MyPantryPage> createState() => _MyPantryPageState();
}

class _MyPantryPageState extends State<MyPantryPage> {
  late final UserCubit _userCubit;
  late final PantryBloc _pantryBloc;
  final TextEditingController _searchController = TextEditingController();

  PantryFilter _selectedFilter = PantryFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _pantryBloc = context.read<PantryBloc>();

    _selectedFilter = _getInitialFilter();
    _initializePantry();
  }

  PantryFilter _getInitialFilter() {
    switch (widget.type) {
      case "expiring_soon":
        return PantryFilter.expiring;
      case "low_stock":
        return PantryFilter.lowStock;
      default:
        return PantryFilter.all;
    }
  }

  Future<void> _initializePantry() async {
    _loadPantryItems();
  }

  void _loadPantryItems() {
    final kitchenId = _userCubit.state.activeKitchenId.trim();

    if (kitchenId.isEmpty) {
      AppToast.show(
        "Please join a kitchen before adding pantry items.",
        ToastType.warning,
      );
      return;
    }
    getPantryItems(kitchenId);
  }

  void getPantryItems(String kitchenId) {
    _pantryBloc.add(GetPantryItemsEvent(kitchenId: kitchenId));
  }

  void _showFilterBottomSheet() {
    FocusScope.of(context).unfocus();

    PantryFilter tempFilter = _selectedFilter;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.4),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: MyPantryFilterSheet(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              tempFilter = filter;
            },
            onApplyFilter: () {
              setState(() {
                _selectedFilter = tempFilter;
              });
              Navigator.pop(context);
              FocusScope.of(context).unfocus();
            },
          ),
        ),
      ),
    );
  }

  List<PantryItemEntity> _getFilteredItems(PantryState state) {
    if (state is! PantryLoaded) return [];

    List<PantryItemEntity> items;
    switch (_selectedFilter) {
      case PantryFilter.expiring:
        items = state.expiringItems;
      case PantryFilter.lowStock:
        items = state.lowStockItems;
      case PantryFilter.all:
        items = state.pantryItems;
    }

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.group.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        context.pushNamed(Routes.dashboard);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: MyPantryAppBar(),
        body: BlocConsumer<PantryBloc, PantryState>(
          listener: (_, state) => _handlePantryStateChange(state),
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(child: _buildContent(state)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: gapOnly(left: 12, right: 12, bottom: 12, top: 4),
      child: AppTextField(
        controller: _searchController,
        isFilled: true,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: gapAll(12),
          child: SvgPicture.asset(AppAssets.searchSvg),
        ),
        suffixIcon: InkWell(
          onTap: _showFilterBottomSheet,
          child: Padding(
            padding: gapAll(12),
            child: SvgPicture.asset(
              AppAssets.filterSvg,
              colorFilter: ColorFilter.mode(
                _selectedFilter != PantryFilter.all
                    ? AppColors.primaryColor
                    : Colors.grey.shade400,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        hintText: 'Search items...',
        label: '',
        isLabled: false,
      ),
    );
  }

  Widget _buildContent(PantryState state) {
    if (state is! PantryLoaded && state is! PantryFailure) {
      return Center(child: Lottie.asset(AppAssets.loader));
    }

    final filteredItems = _getFilteredItems(state);

    return MyPantryItemList(
      items: filteredItems,
      kitchenId: _userCubit.state.activeKitchenId,
      highlightedItemId: widget.itemId,
      onAddToCart: _handleAddToCart,
      hasPremiumAccess: context.read<UserCubit>().state.hasPremiumAccess,
      selectedFilter: _selectedFilter,
    );
  }

  void _handlePantryStateChange(PantryState state) {
    if (state is PantryFailure) {
      AppToast.show(state.errorMessage, ToastType.error);
    } else if (state is PantrySuccess) {
      AppToast.show(state.successMessage, ToastType.success);
    }
  }

  void _handleAddToCart(PantryItemEntity item, int index) {
    _pantryBloc.add(
      CartItemsEvent(
        pantry: Pantry(
          kitchenId: _userCubit.state.activeKitchenId,
          items: [item],
        ),
        index: index,
      ),
    );
  }
}
