// ignore_for_file: unnecessary_underscores
import 'dart:typed_data';
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
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/custom_appbar.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/pantry_item_card.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

enum PantryFilter { all, expiring, lowStock }

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
  late final NotificationService _notificationService;
  final TextEditingController _searchController = TextEditingController();

  PantryFilter _selectedFilter = PantryFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _pantryBloc = context.read<PantryBloc>();
    _notificationService = NotificationService();

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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      barrierColor: Colors.black.withOpacity(0.4),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: _FilterBottomSheet(
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
        break;
      case PantryFilter.lowStock:
        items = state.lowStockItems;
        break;
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
      onPopInvoked: (didPop) {
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
              color: _selectedFilter != PantryFilter.all
                  ? AppColors.primaryColor
                  : Colors.grey.shade400,
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

    return _PantryItemList(
      items: filteredItems,
      kitchenId: _userCubit.state.activeKitchenId,
      highlightedItemId: widget.itemId,
      onAddToCart: _handleAddToCart,
      isPremiumUser: context.read<UserCubit>().state.isPremiumUser,
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

class _FilterBottomSheet extends StatefulWidget {
  final PantryFilter selectedFilter;
  final Function(PantryFilter) onFilterChanged;
  final VoidCallback onApplyFilter;

  const _FilterBottomSheet({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onApplyFilter,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late PantryFilter _tempSelectedFilter;

  @override
  void initState() {
    super.initState();
    _tempSelectedFilter = widget.selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: gapSymmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: w(60),
              height: h(3),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(h(88)),
              ),
            ),
          ),
          gap(height: 18),
          Center(
            child: Text(
              "Filter Items",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          gap(height: 20),
          _FilterOption(
            title: 'All Items',
            subtitle: 'Show all pantry items',
            icon: Icons.inventory_2_outlined,
            isSelected: _tempSelectedFilter == PantryFilter.all,
            onTap: () {
              setState(() {
                _tempSelectedFilter = PantryFilter.all;
              });
              widget.onFilterChanged(PantryFilter.all);
            },
          ),
          gap(height: 12),
          _FilterOption(
            title: 'Expiring Soon',
            subtitle: 'Items that are about to expire',
            icon: Icons.access_time,
            isSelected: _tempSelectedFilter == PantryFilter.expiring,
            onTap: () {
              setState(() {
                _tempSelectedFilter = PantryFilter.expiring;
              });
              widget.onFilterChanged(PantryFilter.expiring);
            },
          ),
          gap(height: 12),
          _FilterOption(
            title: 'Low Stock',
            subtitle: 'Items running low',
            icon: Icons.warning_amber_outlined,
            isSelected: _tempSelectedFilter == PantryFilter.lowStock,
            onTap: () {
              setState(() {
                _tempSelectedFilter = PantryFilter.lowStock;
              });
              widget.onFilterChanged(PantryFilter.lowStock);
            },
          ),
          gap(height: 20),
          GenericButtonWidget(
            onPressed: widget.onApplyFilter,
            text: "Apply Filter",
          ),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF757575),
                size: 24,
              ),
            ),
            gap(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  gap(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PantryItemList extends StatelessWidget {
  final List<PantryItemEntity> items;
  final String kitchenId;
  final String highlightedItemId;
  final void Function(PantryItemEntity item, int index) onAddToCart;

  final bool isPremiumUser;
  final PantryFilter selectedFilter;

  const _PantryItemList({
    required this.items,
    required this.kitchenId,
    required this.highlightedItemId,
    required this.onAddToCart,
    required this.isPremiumUser,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _buildEmptyState(context);

    final sortedItems = _getSortedItems();

    return ListView.separated(
      itemCount: sortedItems.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      separatorBuilder: (_, __) =>
          const Divider(color: Color(0xFFF4F4F4), height: 1),
      padding: gapSymmetric(horizontal: 12, vertical: 12),
      itemBuilder: (context, index) {
        final item = sortedItems[index];

        final isHighlighted =
            highlightedItemId.isNotEmpty && item.itemId == highlightedItemId;

        final isLocked = _isItemLocked(sortedItems, index);

        return _buildItem(
          selectedFilter: selectedFilter,
          context: context,
          item: item,
          index: index,
          isHighlighted: isHighlighted,
          isLocked: isLocked,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          gap(height: 16),
          Text(
            "No Items found",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required PantryItemEntity item,
    required int index,
    required bool isHighlighted,
    required bool isLocked,
    required PantryFilter selectedFilter,
  }) {
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          AppToast.show("Upgrade to unlock all items", ToastType.warning);
          return;
        }
        onAddToCart(item, index);
      },
      child: Padding(
        padding: gapOnly(bottom: 16),
        child: _PantryItemTile(
          selectedFilter: selectedFilter,
          isLocked: isLocked,
          item: item,
          kitchenId: kitchenId,
          isHighlighted: isHighlighted,
          onAddToCart: () => onAddToCart(item, index),
        ),
      ),
    );
  }

  List<PantryItemEntity> _getSortedItems() {
    if (selectedFilter == PantryFilter.expiring) {
      return [...items]..sort((a, b) => a.expireDate.compareTo(b.expireDate));
    }

    if (selectedFilter == PantryFilter.lowStock) {
      return [...items]..sort((a, b) => a.quantity.compareTo(b.quantity));
    }

    final expiring =
        items.where((e) => e.expiryStatus == "expiring_soon").toList()
          ..sort((a, b) => a.expireDate.compareTo(b.expireDate));

    final lowStock = items.where((e) => e.stockStatus == "low_stock").toList()
      ..sort((a, b) => a.quantity.compareTo(b.quantity));

    final others = items
        .where(
          (e) =>
              e.expiryStatus != "expiring_soon" && e.stockStatus != "low_stock",
        )
        .toList();

    return [...expiring, ...lowStock, ...others];
  }

  bool _isItemLocked(List<PantryItemEntity> sortedItems, int index) {
    if (isPremiumUser) return false;

    if (selectedFilter == PantryFilter.all) {
      return false;
    }

    return index >= 3;
  }
}

class _PantryItemTile extends StatefulWidget {
  final PantryItemEntity item;
  final PantryFilter selectedFilter;
  final String kitchenId;
  final bool isHighlighted;
  final bool isLocked;
  final VoidCallback onAddToCart;

  const _PantryItemTile({
    required this.item,
    required this.kitchenId,
    required this.isLocked,
    required this.selectedFilter,
    required this.isHighlighted,
    required this.onAddToCart,
  });

  @override
  State<_PantryItemTile> createState() => _PantryItemTileState();
}

class _PantryItemTileState extends State<_PantryItemTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.isHighlighted) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );

      _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _animationController.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _animationController.stop();
          _animationController.value = 1.0;
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.isHighlighted) {
      _animationController.dispose();
    }
    super.dispose();
  }

  String get _expiryText {
    return widget.item.expireDate.isEmpty ? "" : widget.item.expireDate;
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowBorder =
        widget.isHighlighted ||
        widget.item.expiryStatus == "expiring_soon" ||
        widget.item.stockStatus == "low_stock";

    final Widget cardWidget = Container(
      decoration: shouldShowBorder && widget.selectedFilter != PantryFilter.all
          ? BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              border: Border.all(color: Colors.red, width: 0.5),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: PantryItemCard(
        selectedFilter: widget.selectedFilter,
        isLocked: widget.isLocked,
        thumbnail: widget.item.thumbnailBytes ?? Uint8List(0),
        title: widget.item.name,
        quantity: widget.item.quantity.toString(),
        unit: widget.item.unit,
        pantry: widget.item.group,
        expiry: _expiryText,
        onListCheckedCallback: () async {},
        onCartItem: widget.onAddToCart,
        pantryItemEntity: widget.item,
        kitchenId: widget.kitchenId,
      ),
    );

    if (widget.isHighlighted) {
      return AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(opacity: _opacityAnimation.value, child: child);
        },
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
