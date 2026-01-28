// ignore_for_file: unnecessary_underscores

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
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
import 'package:lottie/lottie.dart';

class MyPantryPage extends StatefulWidget {
  const MyPantryPage({super.key});

  @override
  State<MyPantryPage> createState() => _MyPantryPageState();
}

class _MyPantryPageState extends State<MyPantryPage> {
  late final UserCubit _userCubit;
  late final PantryBloc _pantryBloc;
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _pantryBloc = context.read<PantryBloc>();
    _notificationService = NotificationService();

    _initializePantry();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: MyPantryAppBar(),
        body: BlocConsumer<PantryBloc, PantryState>(
          listener: (_, state) => _handlePantryStateChange(state),
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(child: _buildContent(state)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primaryColor, width: h(2)),
          ),
        ),
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: const Color(0xFF787878),
        tabs: const [
          Tab(text: "All Items"),
          Tab(text: "Expiring"),
          Tab(text: "Low Stock"),
        ],
      ),
    );
  }

  Widget _buildContent(PantryState state) {
    if (state is! PantryLoaded) {
      return Center(child: Lottie.asset(AppAssets.loader));
    }

    return TabBarView(
      children: [
        _PantryItemList(
          items: state.pantryItems,
          kitchenId: _userCubit.state.activeKitchenId,
          onAddToCart: _handleAddToCart,
        ),
        _PantryItemList(
          items: state.expiringItems,
          kitchenId: _userCubit.state.activeKitchenId,
          onAddToCart: _handleAddToCart,
        ),
        _PantryItemList(
          items: state.lowStockItems,
          kitchenId: _userCubit.state.activeKitchenId,
          onAddToCart: _handleAddToCart,
        ),
      ],
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

class _PantryItemList extends StatelessWidget {
  final List<PantryItemEntity> items;
  final String kitchenId;
  final void Function(PantryItemEntity item, int index) onAddToCart;

  const _PantryItemList({
    required this.items,
    required this.kitchenId,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
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
      separatorBuilder: (_, __) =>
          const Divider(color: Color(0xFFF4F4F4), height: 1),
      padding: gapSymmetric(horizontal: 12, vertical: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: gapOnly(bottom: 8),
          child: _PantryItemTile(
            item: item,
            kitchenId: kitchenId,
            onAddToCart: () => onAddToCart(item, index),
          ),
        );
      },
    );
  }
}

class _PantryItemTile extends StatelessWidget {
  final PantryItemEntity item;
  final String kitchenId;
  final VoidCallback onAddToCart;

  const _PantryItemTile({
    required this.item,
    required this.kitchenId,
    required this.onAddToCart,
  });

  String get _expiryText {
    return item.expireDate.isEmpty ? "Expire in 2 days" : item.expireDate;
  }

  @override
  Widget build(BuildContext context) {
    return PantryItemCard(
      thumbnail: item.thumbnailBytes ?? Uint8List(0),
      title: item.name,
      quantity: item.quantity.toString(),
      unit: item.unit,
      pantry: item.group,
      expiry: _expiryText,
      onListCheckedCallback: () async {},
      onCartItem: onAddToCart,
      pantryItemEntity: item,
      kitchenId: kitchenId,
    );
  }
}
