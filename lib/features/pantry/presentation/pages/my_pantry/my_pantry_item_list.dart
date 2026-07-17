import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/my_pantry/my_pantry_filter_sheet.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/pantry_item_card.dart';

class MyPantryItemList extends StatelessWidget {
  const MyPantryItemList({
    super.key,
    required this.items,
    required this.kitchenId,
    required this.highlightedItemId,
    required this.onAddToCart,
    required this.hasPremiumAccess,
    required this.selectedFilter,
  });

  final List<PantryItemEntity> items;
  final String kitchenId;
  final String highlightedItemId;
  final void Function(PantryItemEntity item, int index) onAddToCart;
  final bool hasPremiumAccess;
  final PantryFilter selectedFilter;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _buildEmptyState(context);

    final sortedItems = _getSortedItems();

    return ListView.separated(
      itemCount: sortedItems.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      separatorBuilder: (_, _) =>
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
      key: ValueKey(item.itemId),
      onTap: () {
        if (isLocked) {
          AppToast.show("Upgrade to unlock all items", ToastType.warning);
          return;
        }
        onAddToCart(item, index);
      },
      child: Padding(
        padding: gapOnly(bottom: 16),
        child: MyPantryItemTile(
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
    if (hasPremiumAccess) return false;

    if (selectedFilter == PantryFilter.all) {
      return false;
    }

    return index >= 3;
  }
}

class MyPantryItemTile extends StatefulWidget {
  const MyPantryItemTile({
    super.key,
    required this.item,
    required this.kitchenId,
    required this.isLocked,
    required this.selectedFilter,
    required this.isHighlighted,
    required this.onAddToCart,
  });

  final PantryItemEntity item;
  final PantryFilter selectedFilter;
  final String kitchenId;
  final bool isHighlighted;
  final bool isLocked;
  final VoidCallback onAddToCart;

  @override
  State<MyPantryItemTile> createState() => _MyPantryItemTileState();
}

class _MyPantryItemTileState extends State<MyPantryItemTile>
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
              color: AppColors.primaryColor.withValues(alpha: 0.1),
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
