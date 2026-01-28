// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';

class HeaderImageWidget extends StatelessWidget {
  final bool isFavorite;
  final Uint8List? thumbnailBytes;
  final VoidCallback onFavoritePressed;

  const HeaderImageWidget({
    super.key,
    required this.isFavorite,
    this.thumbnailBytes,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(left: 20, right: 20, top: 20),
      child: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          return Container(
            height: h(154),
            width: double.infinity,
            padding: gapAll(15),
            alignment: Alignment.topRight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(h(10)),
              image: _buildBackgroundImage(),
            ),
            child: _buildFavoriteButton(state),
          );
        },
      ),
    );
  }

  DecorationImage _buildBackgroundImage() {
    if (thumbnailBytes != null && thumbnailBytes!.isNotEmpty) {
      return DecorationImage(
        image: MemoryImage(thumbnailBytes!),
        fit: BoxFit.cover,
      );
    }

    return DecorationImage(
      image: AssetImage(AppAssets.onBoardingSliderBg02),
      fit: BoxFit.cover,
    );
  }

  Widget _buildFavoriteButton(PlannerState state) {
    final isLoading = state.isLoading;

    return GestureDetector(
      onTap: isLoading ? null : onFavoritePressed,
      child: CircleAvatar(
        radius: h(18),
        backgroundColor: Colors.grey.withOpacity(0.75),
        child: isLoading ? _buildLoadingIndicator() : _buildFavoriteIcon(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Transform.scale(
      scale: 0.5,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildFavoriteIcon() {
    return SvgPicture.asset(
      isFavorite ? AppAssets.favouriteFilledSvg : AppAssets.favouriteSvg,
      height: h(18),
    );
  }
}
