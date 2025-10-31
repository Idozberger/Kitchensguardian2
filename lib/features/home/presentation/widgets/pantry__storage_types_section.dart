import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';
import 'package:go_router/go_router.dart';

class PantryStorageTypeSection extends StatefulWidget {
  final HomeState state;

  const PantryStorageTypeSection({super.key, required this.state});

  @override
  State<PantryStorageTypeSection> createState() =>
      _PantryStorageTypeSectionState();
}

class _PantryStorageTypeSectionState extends State<PantryStorageTypeSection> {
  bool hasItems = false;
  @override
  void initState() {
    if (widget.state.pantryItems.isNotEmpty) {
      hasItems = widget.state.pantryItems[0].pantryTypes.isNotEmpty;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          gap(height: 15),
          _actionButtons(context, hasItems),
          gap(height: 15),
          if (hasItems) _pantryList(context) else _noItemsText(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("Pantry Types", style: Theme.of(context).textTheme.headlineLarge),
      SvgPicture.asset(AppAssets.pantrySvg),
    ],
  );

  Widget _actionButtons(BuildContext context, bool hasItems) => Row(
    children: [
      if (!hasItems)
        Expanded(
          child: SizedBox(
            height: h(40),
            child: OutlinedButton.icon(
              onPressed: () => context.push(Routes.scanMeal),
              icon: SvgPicture.asset(AppAssets.scanSvg),
              label: Text(
                "Scan",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(12),
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
      if (!hasItems) gap(width: 10),
      Expanded(
        child: SizedBox(
          height: h(40),
          child: ElevatedButton.icon(
            onPressed: () => context.push(Routes.addPantryStorageType),
            icon: SvgPicture.asset(AppAssets.addSvg),
            label: Text(
              "Add Area",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: t(12),
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _pantryList(BuildContext context) => Column(
    children: [
      ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.state.pantryItems[0].items.length.clamp(0, 3),
        separatorBuilder: (_, __) => const Divider(color: Color(0xffF4F4F4)),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final pantry = widget.state.pantryItems[0].items[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListItemWidget(
                  text: pantry.name,
                  textStyle: Theme.of(context).textTheme.headlineSmall!
                      .copyWith(
                        fontSize: t(12),
                        color: const Color(0xff787878),
                      ),
                  crossAlignment: CrossAxisAlignment.center,
                ),
              ),
              Text(
                pantry.quantity.toString(),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(12),
                  color: const Color(0xff787878),
                ),
              ),
            ],
          );
        },
      ),
      gap(height: 15),
      Center(
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
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: t(12),
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _noItemsText(BuildContext context) => Text(
    "No storage areas available",
    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: t(12),
      color: const Color(0xff787878),
    ),
  );
}
