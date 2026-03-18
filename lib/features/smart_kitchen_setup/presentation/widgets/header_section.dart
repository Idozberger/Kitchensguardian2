import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(left: 0, right: 0, top: 0, bottom: 0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapVertical(12),
          Text.rich(
            TextSpan(
              text:
                  'For the most accurate results, take clear, detailed photos — these will help ',
              children: [
                TextSpan(
                  text: 'KitchenGuardian',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff787878),
                    fontSize: t(14),
                  ),
                ),
                const TextSpan(
                  text:
                      ' understand your kitchen and improve accuracy over time.',
                ),
              ],
            ),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: const Color(0xff787878),
              fontSize: t(14),
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          gapVertical(8),
          UpperTile(
            color: const Color(0x33FFBD4A),
            widget: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset(AppAssets.bulbSvg),
                ),
                SizedBox(width: w(10)),
                Expanded(
                  child: Text(
                    'Detailed photos = more accurate results. Take your time!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Color(0xff787878),
                      fontSize: t(12),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
