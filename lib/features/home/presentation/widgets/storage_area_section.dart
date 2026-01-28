// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';
import 'package:go_router/go_router.dart';

class StorageAreasSection extends StatelessWidget {
  final UserState state;

  const StorageAreasSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, homeState) {
        final hasStorageAreas = state.userStorageAreas.isNotEmpty;

        return Column(
          children: [
            BlocBuilder<UserCubit, UserState>(
              builder: (_, userState) {
                return Padding(
                  padding: gapOnly(left: 20, right: 20, bottom: 0, top: 14),
                  child: UpperTile(
                    widget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(context),

                        if (hasStorageAreas ||
                            userState.userStorageAreas.isNotEmpty)
                          Column(
                            children: [
                              gap(height: 14),
                              _actionButtons(context, userState),
                            ],
                          ),

                        if (userState.userStorageAreas.isEmpty)
                          _addStorageButton(context),

                        gap(height: 14),
                        hasStorageAreas
                            ? _storageList(context)
                            : _noStorageText(context),
                      ],
                    ),
                  ),
                );
              },
            ),
            gap(height: 124),
            Padding(
              padding: gapSymmetric(horizontal: 42),
              child: EmptyStateWidget(
                context,
                imagePath: AppAssets.noKitchenFound,
                title: 'No storage areas added yet',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("Storage Areas", style: Theme.of(context).textTheme.headlineLarge),
      SvgPicture.asset(AppAssets.pantrySvg),
    ],
  );

  Widget _actionButtons(BuildContext context, UserState userState) {
    final disabled = userState.userStorageAreas.isEmpty;

    return SizedBox(
      height: h(40),
      child: ElevatedButton.icon(
        onPressed: disabled
            ? null
            : () => context.push(Routes.addPantryStorageType),
        icon: SvgPicture.asset(AppAssets.addSvg),
        label: Text(
          "Add Storage",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: t(12),
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _addStorageButton(BuildContext context) => Padding(
    padding: gapOnly(top: 14),
    child: SizedBox(
      height: h(40),
      child: ElevatedButton.icon(
        onPressed: () => context.push(Routes.addPantryStorageType),
        icon: SvgPicture.asset(AppAssets.addSvg),
        label: Text(
          "Add Storage Area",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: t(12),
            color: Colors.black,
          ),
        ),
      ),
    ),
  );

  Widget _storageList(BuildContext context) => Column(
    children: [
      ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: state.userStorageAreas.length.clamp(0, 3),
        separatorBuilder: (_, __) => const Divider(color: Color(0xffF4F4F4)),
        itemBuilder: (_, index) {
          final area = state.userStorageAreas[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListItemWidget(
                  text: area.pantryName,
                  crossAlignment: CrossAxisAlignment.center,
                  textStyle: Theme.of(context).textTheme.headlineSmall!
                      .copyWith(
                        fontSize: t(12),
                        color: const Color(0xff787878),
                      ),
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
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

  Widget _noStorageText(BuildContext context) => Text(
    "No storage areas available",
    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: t(12),
      color: const Color(0xff787878),
    ),
  );
}
