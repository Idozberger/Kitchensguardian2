import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';

class HeaderImageWidget extends StatelessWidget {
  final bool isFav;
  final String thumbnail;
  final VoidCallback onFavoriteToggle;

  const HeaderImageWidget({
    super.key,
    required this.isFav,
    required this.thumbnail,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(left: 20, right: 20, top: 20),
      child: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (_, state) {
          return Container(
            padding: gapAll(15),
            alignment: Alignment.topRight,
            height: h(154),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(h(10)),
              image: (thumbnail.isNotEmpty)
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(thumbnail),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage(AppAssets.onBoardingSliderBg02),
                      fit: BoxFit.cover,
                    ),
            ),
            child: GestureDetector(
              onTap: state.isLoading ? null : onFavoriteToggle,
              child: CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.8),
                child: state.isLoading
                    ? Transform.scale(
                        scale: 0.5,
                        child: const CircularProgressIndicator(),
                      )
                    : SvgPicture.asset(
                        isFav
                            ? AppAssets.favouriteFilledSvg
                            : AppAssets.favouriteSvg,
                        height: h(14),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
