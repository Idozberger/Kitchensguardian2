// ignore_for_file: deprecated_member_use

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
      builder: (_, homeState) {
        final bool hasItems =
            homeState.pantryItems.isNotEmpty &&
            homeState.pantryItems[0].items.isNotEmpty;
        return BlocBuilder<UserCubit, UserState>(
          builder: (_, userState) {
            return UpperTile(
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  if (hasItems || userState.userStorageAreas.isNotEmpty)
                    Column(
                      children: [
                        gap(height: 14),

                        _actionButtons(context, hasItems, userState),
                      ],
                    ),
                  if (userState.userStorageAreas.isEmpty)
                    Padding(
                      padding: gapOnly(top: 14),
                      child: SizedBox(
                        height: h(40),
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.push(Routes.addPantryStorageType),
                          icon: SvgPicture.asset(AppAssets.addSvg),
                          label: Text(
                            "Add Pantry",
                            style: Theme.of(context).textTheme.headlineMedium!
                                .copyWith(fontSize: t(12), color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  gap(height: 14),
                  if (hasItems) _pantryList(context) else _noItemsText(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("Pantry", style: Theme.of(context).textTheme.headlineLarge),
      SvgPicture.asset(AppAssets.pantrySvg),
    ],
  );

  Widget _actionButtons(
    BuildContext context,
    bool hasItems,
    UserState userState,
  ) => Row(
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
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.state.pantryItems[0].items.length.clamp(0, 3),
        separatorBuilder: (_, _) => const Divider(color: Color(0xffF4F4F4)),
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
    "No items available in Pantry",
    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: t(12),
      color: const Color(0xff787878),
    ),
  );
}
