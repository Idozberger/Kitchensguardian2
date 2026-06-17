// ignore_for_file: deprecated_member_use
// Color.opacity / image APIs pending migration to withValues-style APIs.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/core/widgets/safe_memory_image.dart';
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
          return ClipRRect(
            borderRadius: BorderRadius.circular(h(10)),
            child: SizedBox(
            height: h(154),
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SafeMemoryImage(
                  bytes: thumbnailBytes,
                  fit: BoxFit.cover,
                  fallback: Image.asset(
                    AppAssets.onBoardingSliderBg02,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: gapAll(15),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: _buildFavoriteButton(state),
                  ),
                ),
              ],
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteButton(PlannerState state) {
    final isLoading = state.isFavLoading;

    return GestureDetector(
      onTap: isLoading ? null : onFavoritePressed,
      child: CircleAvatar(
        radius: h(18),
        backgroundColor: Colors.grey.withValues(alpha: 0.75),
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
