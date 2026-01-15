import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';
import 'package:go_router/go_router.dart';

class PantrySection extends StatefulWidget {
  final HomeState state;

  const PantrySection({super.key, required this.state});

  @override
  State<PantrySection> createState() => _PantrySectionState();
}

class _PantrySectionState extends State<PantrySection> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        final hasItems = _hasItems(homeState);
        return BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) =>
              _buildPantryTile(context, hasItems, userState),
        );
      },
    );
  }

  Widget _buildPantryTile(
    BuildContext context,
    bool hasItems,
    UserState userState,
  ) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (hasItems || userState.userStorageAreas.isNotEmpty) ...[
            gap(height: 14),
            _buildActionButtons(context, hasItems, userState),
          ],
          if (userState.userStorageAreas.isEmpty)
            _buildAddPantryButton(context),
          gap(height: 14),
          if (hasItems)
            _buildPantryList(context)
          else
            _buildEmptyState(context),
        ],
      ),
    );
  }

  bool _hasItems(HomeState homeState) {
    return homeState.pantryItems.isNotEmpty &&
        homeState.pantryItems[0].items.isNotEmpty;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Pantry", style: Theme.of(context).textTheme.headlineLarge),
        SvgPicture.asset(AppAssets.pantrySvg),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool hasItems,
    UserState userState,
  ) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: h(40),
            child: ElevatedButton.icon(
              onPressed: userState.userStorageAreas.isEmpty
                  ? null
                  : () => context.push(Routes.addItem),
              icon: SvgPicture.asset(AppAssets.addSvg),
              label: Text(
                "Add Item",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: t(12),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPantryButton(BuildContext context) {
    return Padding(
      padding: gapOnly(top: 14),
      child: SizedBox(
        height: h(40),
        child: ElevatedButton.icon(
          onPressed: () => context.push(Routes.addPantryStorageType),
          icon: SvgPicture.asset(AppAssets.addSvg),
          label: Text(
            "Add Pantry",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: t(12),
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPantryList(BuildContext context) {
    return Column(
      children: [
        _buildPantryListView(context),
        gap(height: 15),
        _buildSeeMoreButton(context),
      ],
    );
  }

  Widget _buildPantryListView(BuildContext context) {
    final items = widget.state.pantryItems[0].items;
    final displayCount = items.length.clamp(0, 3);

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: displayCount,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFFF4F4F4)),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) =>
          _buildPantryItemRow(context, items[index]),
    );
  }

  Widget _buildPantryItemRow(BuildContext context, dynamic pantry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: ListItemWidget(
            text: pantry.name,
            textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: t(12),
              color: const Color(0xFF787878),
            ),
            crossAlignment: CrossAxisAlignment.center,
          ),
        ),
        Text(
          pantry.quantity.toString(),
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
          onPressed: () => context.push(Routes.myPantry),
          icon: SvgPicture.asset(
            AppAssets.eyeSvg,
            color: AppColors.primaryColor,
            width: w(10),
            height: h(10),
          ),
          label: Text(
            "Tap to see more",
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
      "No items available in Pantry",
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: t(12),
        color: const Color(0xFF787878),
      ),
    );
  }
}
