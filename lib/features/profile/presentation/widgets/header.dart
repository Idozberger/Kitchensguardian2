import 'dart:convert';
import 'dart:io';

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
                  profileState.imagePath != null
                      ? CircleAvatar(
                          radius: w(36),
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: MemoryImage(profileState.imagePath!),
                        )
                      : Image.asset(
                          AppAssets.avatar,
                          width: w(72),
                          height: h(72),
                        ),
                  SizedBox(width: w(20)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: h(5),
                    children: [
                      Text(
                        "${state.firstName} ${state.lastName}",
                        style: Theme.of(context).textTheme.headlineLarge,
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
                children: const [
                  ProfileStatTile(title: "Meals Planned", value: "12"),
                  ProfileStatTile(title: "Shopping Lists", value: "10"),
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
                    color: AppColors.primaryColor,
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
