import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class GenericCircleCheckboxTile extends StatelessWidget {
  final String title;
  final String quantity;
  final String unit;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? deleteCallback;
  final VoidCallback? editCallback;
  final Color activeColor;
  final Color checkColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry contentPadding;
  final bool isFinalList;
  const GenericCircleCheckboxTile({
    super.key,
    required this.title,
    required this.isChecked,
    required this.unit,
    required this.onChanged,
    required this.quantity,
    this.deleteCallback,
    this.editCallback,
    required this.activeColor,
    this.checkColor = Colors.white,
    this.isFinalList = false,
    this.textStyle,

    this.contentPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: contentPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Row(
              children: [
                InkWell(
                  onTap: () => onChanged(!isChecked),
                  child: Container(
                    padding: gapAll(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                      color: isChecked ? activeColor : Colors.transparent,
                    ),
                    child: Icon(Icons.check, size: t(12), color: checkColor),
                  ),
                ),
                SizedBox(width: w(14)),

                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(!isChecked),
                    child: Text(
                      title,
                      style:
                          textStyle ??
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                            decoration: isFinalList && isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: isFinalList ? null : FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                // Text(
                //   "$quantity $unit",
                //   style:
                //       textStyle ??
                //       Theme.of(context).textTheme.headlineSmall!.copyWith(
                //         decoration: isFinalList && isChecked
                //             ? TextDecoration.lineThrough
                //             : null,
                //         fontWeight: isFinalList && isChecked
                //             ? FontWeight.w400
                //             : FontWeight.w500,
                //       ),
                // ),
              ],
            ),
          ),
          if (deleteCallback != null)
            Padding(
              padding: gapOnly(left: 8),
              child: GestureDetector(
                onTap: deleteCallback,
                child: Container(
                  padding: gapAll(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffD4D2D2)),
                    shape: BoxShape.circle,
                  ),

                  child: SvgPicture.asset(AppAssets.deleteSvg),
                ),
              ),
            ),
          if (editCallback != null)
            Padding(
              padding: gapOnly(left: 8),
              child: GestureDetector(
                onTap: editCallback,
                child: Container(
                  padding: gapAll(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffD4D2D2)),
                    shape: BoxShape.circle,
                  ),

                  child: SvgPicture.asset(AppAssets.editSvg),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
