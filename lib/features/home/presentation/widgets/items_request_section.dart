import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/domain/entities/item_request.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';
import 'package:go_router/go_router.dart';

class ItemRequestSection extends StatefulWidget {
  final HomeState state;

  const ItemRequestSection({super.key, required this.state});

  @override
  State<ItemRequestSection> createState() => _ItemRequestSectionState();
}

class _ItemRequestSectionState extends State<ItemRequestSection> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        final hasRequests = _hasRequests(homeState);
        return BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) =>
              _buildRequestTile(context, hasRequests, userState),
        );
      },
    );
  }

  bool _hasRequests(HomeState state) {
    return state.itemsRequest.isNotEmpty;
  }

  Widget _buildRequestTile(
    BuildContext context,
    bool hasRequests,
    UserState userState,
  ) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),

          gap(height: 14),
          hasRequests ? _buildRequestList(context) : _buildEmptyState(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      "Item Requests",
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }

  Widget _buildRequestList(BuildContext context) {
    final requests = widget.state.itemsRequest;
    final displayCount = requests.length.clamp(0, 3);

    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: displayCount,
          separatorBuilder: (_, _) => const Divider(color: Color(0xFFF4F4F4)),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) =>
              _buildRequestRow(context, requests[index]),
        ),
        gap(height: 15),
        _buildSeeMoreButton(context),
      ],
    );
  }

  Widget _buildRequestRow(BuildContext context, ItemRequest request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: ListItemWidget(
            text: request.name,
            textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: t(12),
              color: const Color(0xFF787878),
            ),
            crossAlignment: CrossAxisAlignment.center,
          ),
        ),
        Text(
          formatQuantity(request.quantity),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: t(12),
            color: const Color(0xFF787878),
          ),
        ),
      ],
    );
  }

  Widget _buildSeeMoreButton(BuildContext context) {
    return Center(
      child: SizedBox(
        height: h(40),
        width: w(170),
        child: OutlinedButton.icon(
          onPressed: () => context.push(Routes.itemRequestsDetails),
          icon: SvgPicture.asset(
            AppAssets.eyeSvg,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.srcIn,
            ),
            width: w(10),
            height: h(10),
          ),
          label: Text(
            "Tap for details",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: t(12),
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Text(
      "No item requests available",
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: t(12),
        color: const Color(0xFF787878),
      ),
    );
  }
}
