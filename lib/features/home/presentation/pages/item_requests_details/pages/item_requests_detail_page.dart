import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/empty_state.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/filter_app_bar.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/item_request_card.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/items_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class ItemRequestsDetailPage extends StatefulWidget {
  const ItemRequestsDetailPage({super.key});

  @override
  State<ItemRequestsDetailPage> createState() => _ItemRequestsDetailPageState();
}

class _ItemRequestsDetailPageState extends State<ItemRequestsDetailPage> {
  ItemRequestFilter _selectedFilter = ItemRequestFilter.all;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(
      GetAllRequestedItemsEvent(
        kitchenId: context.read<UserCubit>().state.activeKitchenId,
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: FilterBottomSheet(
          selectedFilter: _selectedFilter,

          onApplyFilter: (filter) {
            setState(() => _selectedFilter = filter);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _buildBackButton(context),
        title: Text(
          "Item Requests",
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: t(16)),
        ),
        centerTitle: true,
        actions: [
          FilterAppBarButton(
            selectedFilter: _selectedFilter,
            onTap: _showFilterBottomSheet,
          ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.approveRejectError != null) {
            AppToast.show(state.approveRejectError!, ToastType.error);
            context.read<HomeBloc>().add(
              GetAllRequestedItemsEvent(
                kitchenId: context.read<UserCubit>().state.activeKitchenId,
              ),
            );
          }
          if (state.approveRejectSuccess != null) {
            AppToast.show(state.approveRejectSuccess!, ToastType.success);

            context.read<HomeBloc>().add(
              GetAllRequestedItemsEvent(
                kitchenId: context.read<UserCubit>().state.activeKitchenId,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.itemsRequestLoading) {
            return Center(child: Lottie.asset("assets/lotties/loader.json"));
          }

          final filtered = _selectedFilter == ItemRequestFilter.all
              ? state.itemsRequest
              : state.itemsRequest
                    .where((e) => e.status == _selectedFilter.value)
                    .toList();

          if (filtered.isEmpty) return const EmptyState();

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: w(16), vertical: h(12)),
            itemCount: filtered.length,
            itemBuilder: (context, index) => Padding(
              padding: gapOnly(top: 8),
              child: ItemRequestCard(request: filtered[index], state: state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: w(16)),
        CircularIconButton(
          iconAsset: AppAssets.backArrowiOS,
          onTap: () => context.pop(),
        ),
      ],
    );
  }
}
