import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_state.dart';
import 'package:foodkitchen/features/profile/presentation/widgets/star_tile.dart';
import 'package:go_router/go_router.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileState profileState;
  const ProfileHeader({super.key, required this.profileState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, state) {
        return UpperTile(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SafeCircleAvatar(
                    radius: w(36),
                    memoryBytes: state.profilePictureFilePath,
                    backgroundColor: Colors.grey.shade200,
                    fallback: Image.asset(
                      AppAssets.avatar,
                      width: w(72),
                      height: h(72),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: w(20)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: h(5),
                    children: [
                      SizedBox(
                        width: w(200),
                        child: Text(
                          "${state.firstName} ${state.lastName}",
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineLarge!
                              .copyWith(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      Text(
                        state.email,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium!.copyWith(fontSize: t(12)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: h(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BlocBuilder<PlannerBloc, PlannerState>(
                    builder: (_, state) {
                      final int totalMeals = state.getAllWeeklyPlans
                          .map(
                            (e) =>
                                (e.breakfast != null ? 1 : 0) +
                                (e.lunch != null ? 1 : 0) +
                                (e.dinner != null ? 1 : 0),
                          )
                          .fold(0, (a, b) => a + b);

                      return ProfileStatTile(
                        title: "Meals Planned",
                        value: totalMeals == 0 ? "None" : totalMeals.toString(),
                      );
                    },
                  ),
                  BlocBuilder<GroceryBloc, GroceryState>(
                    builder: (_, state) {
                      return ProfileStatTile(
                        title: "Shopping Lists",
                        value: (state.finalListItemsList != null)
                            ? state.finalListItemsList!.isEmpty
                                  ? "None"
                                  : state.finalListItemsList!.length.toString()
                            : "0",
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: h(15)),
              SizedBox(
                width: double.infinity,
                height: h(40),
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(Routes.editProfile);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  icon: SvgPicture.asset(
                    AppAssets.editSvg,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: Text(
                    "Edit Profile",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: t(13),
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
