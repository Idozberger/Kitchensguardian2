import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

class PantryItemCard extends StatefulWidget {
  final String title;
  final String quantity;
  final String unit;
  final String pantry;
  final String expiry;

  const PantryItemCard({
    super.key,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.pantry,
    required this.expiry,
  });

  @override
  State<PantryItemCard> createState() => _PantryItemCardState();
}

class _PantryItemCardState extends State<PantryItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
      },
      child: Container(
        margin: gapSymmetric(vertical: 0),
        padding: gapAll(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(h(10)),
          border: Border.all(color: const Color(0xffD4D2D2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    if (!_isExpanded) ...[
                      SizedBox(width: w(12)),
                      _buildInlineInfo(widget.quantity),
                      _dot(),
                      _buildInlineInfo(widget.unit),
                      _dot(),
                      _buildInlineInfo(widget.pantry),
                    ],
                  ],
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(AppAssets.downArrow),
                ),
              ],
            ),

            /// Expanded Details
            if (_isExpanded) ...[
              SizedBox(height: h(15)),
              Row(
                children: [
                  _buildInlineInfo(widget.quantity),
                  _dot(),
                  _buildInlineInfo(widget.unit),
                  _dot(),
                  _buildInlineInfo(widget.pantry),
                ],
              ),
              SizedBox(height: h(10)),
              Text(
                widget.expiry,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: t(14),
                  color: const Color(0xff787878),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: h(15)),

              /// Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // _circleButton(AppAssets.editSvg, () {}),
                  _circleButton(AppAssets.cartSvg, () {}),
                  _circleButton(AppAssets.listCheckedSvg, () {}),
                  _circleButton(AppAssets.deleteSvg, () {
                    _showDeleteDialog(context);
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineInfo(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: t(14),
        color: const Color(0xff787878),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _dot() => Padding(
    padding: EdgeInsets.symmetric(horizontal: w(8)),
    child: Container(
      width: w(4),
      height: h(4),
      decoration: const BoxDecoration(
        color: Color(0xff787878),
        shape: BoxShape.circle,
      ),
    ),
  );

  Widget _circleButton(String asset, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(left: w(8)),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor),
        shape: BoxShape.circle,
      ),
      child: CircularIconButton(iconAsset: asset, onTap: onTap),
    );
  }

  Future<dynamic> _showDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GenericDialog(
          borderRadius: h(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Remove Item",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(14),
                ),
              ),
              SizedBox(height: h(10)),
              Text(
                "Are you sure you want to delete this item?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(12),
                  color: Color(0xff7B7B7B),
                ),
              ),
              SizedBox(height: h(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SizedBox(
                      height: h(40),
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          AppToast.show("Item removed", ToastType.success);
                          Navigator.pop(context);
                        },

                        child: Text(
                          "Yes",
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                fontSize: t(12),
                                color: AppColors.primaryColor,
                              ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: h(10)),
                  Flexible(
                    child: GenericButtonWidget(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      text: "Cancel",
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
