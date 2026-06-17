import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class PlanComparisonTable extends StatelessWidget {
  final List<PlanFeature> features;

  const PlanComparisonTable({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FixedColumnWidth(w(215)),
        1: FixedColumnWidth(w(60)),
        2: FixedColumnWidth(w(60)),
      },
      border: TableBorder.symmetric(
        inside: BorderSide(color: Colors.transparent),
      ),
      children: [
        TableRow(
          children: [
            const SizedBox(),
            Center(
              child: Text(
                "Free",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Container(
              height: h(40),
              decoration: BoxDecoration(
                color: const Color(0xffC39842),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(h(6)),
                  topRight: Radius.circular(h(6)),
                ),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                AppAssets.crownImage,
                height: h(22),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),

        ...features.map(
          (item) => TableRow(
            children: [
              Text(
                item.title,
                // maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.black),
              ),
              Center(
                child: SvgPicture.asset(
                  item.freeValue ? AppAssets.tickSvg : AppAssets.crossSvg,
                  height: h(15),
                ),
              ),
              Container(
                height: h(38),
                margin: EdgeInsets.symmetric(vertical: h(0)),

                decoration: BoxDecoration(
                  color: const Color(0xffFFE6B4),
                  borderRadius: item.title.contains("grocery")
                      ? BorderRadius.only(
                          bottomLeft: Radius.circular(h(5)),
                          bottomRight: Radius.circular(h(5)),
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  item.premiumValue ? AppAssets.tickSvg : AppAssets.crossSvg,
                  height: h(15),
                  colorFilter: ColorFilter.mode(
                    item.premiumValue
                        ? AppColors.primaryColor
                        : Colors.grey.shade700,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlanFeature {
  final String title;
  final bool freeValue;
  final bool premiumValue;

  PlanFeature({
    required this.title,
    required this.freeValue,
    required this.premiumValue,
  });
}
