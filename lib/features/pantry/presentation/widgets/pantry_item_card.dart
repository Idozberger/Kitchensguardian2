import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:go_router/go_router.dart';

class PantryItemCard extends StatefulWidget {
  final String title;
  final String quantity;
  final String unit;
  final String pantry;
  final VoidCallback onListCheckedCallback;
  final VoidCallback onCartItem;
  final String expiry;
  final PantryItemEntity pantryItemEntity;
  final String kitchenId;

  const PantryItemCard({
    super.key,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.pantry,
    required this.expiry,
    required this.onListCheckedCallback,
    required this.onCartItem,
    required this.pantryItemEntity,
    required this.kitchenId,
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
                    SizedBox(
                      width: _isExpanded ? null : w(54),
                      child: Text(
                        widget.title,
                        maxLines: _isExpanded ? null : 1,
                        overflow: _isExpanded ? null : TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
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

            if (_isExpanded) ...[
              SizedBox(height: h(15)),
              Row(
                children: [
                  _buildInlineInfo(widget.quantity, isExpanded: _isExpanded),
                  _dot(),
                  _buildInlineInfo(widget.unit, isExpanded: _isExpanded),
                  _dot(),
                  _buildInlineInfo(widget.pantry, isExpanded: _isExpanded),
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
                  _circleButton(AppAssets.editSvg, () {
                    _showEditItemDialog(
                      context,
                      widget.pantryItemEntity,
                      widget.kitchenId,
                    );
                  }),
                  _circleButton(AppAssets.cartSvg, widget.onCartItem),
                  _circleButton(
                    AppAssets.listCheckedSvg,
                    () => widget.onListCheckedCallback(),
                  ),
                  _circleButton(AppAssets.deleteSvg, () {
                    _showDeleteDialog(
                      context,
                      widget.pantryItemEntity,
                      widget.kitchenId,
                    );
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineInfo(String text, {bool isExpanded = false}) {
    if (isExpanded) {
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: t(14),
          color: const Color(0xff787878),
          fontWeight: FontWeight.w400,
        ),
      );
    } else {
      return SizedBox(
        width: w(50),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: t(14),
            color: const Color(0xff787878),
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
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
    return Padding(
      padding: EdgeInsets.only(left: w(8)),
      child: CircularIconButton(iconAsset: asset, onTap: onTap),
    );
  }

  Future<dynamic> _showEditItemDialog(
    BuildContext context,
    PantryItemEntity pantryItem,
    String kitchenId,
  ) {
    final TextEditingController itemName = TextEditingController(
      text: pantryItem.name,
    );
    final TextEditingController quantity = TextEditingController(
      text: pantryItem.quantity.toString(),
    );
    String unit = pantryItem.unit;
    String pantry = pantryItem.group;
    final TextEditingController expireDate = TextEditingController(
      text: pantryItem.expireDate,
    );
    return showDialog(
      context: context,
      builder: (context) {
        return GenericDialog(
          borderRadius: h(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _formLabel(context, "Item name"),
              SizedBox(height: h(10)),
              AppTextField(
                textInputAction: TextInputAction.next,
                color: AppColors.apptextFieldStyleTextColor,
                controller: itemName,
                hintText: "Enter item name",
                fillColor: const Color(0xffF9F9F9),
                isFilled: true,
                isLabled: false,
                keyboardType: TextInputType.text,
                label: "",
              ),
              SizedBox(height: h(10)),
              _formLabel(context, "Quantity"),

              SizedBox(height: h(14)),
              AppTextField(
                textInputAction: TextInputAction.next,
                color: AppColors.apptextFieldStyleTextColor,
                controller: quantity,
                hintText: "Enter item quantity",
                fillColor: const Color(0xffF9F9F9),
                isFilled: true,
                keyboardType: TextInputType.number,
                isLabled: false,
                label: "",
              ),
              SizedBox(height: h(15)),
              Row(
                spacing: w(12),
                children: [
                  Flexible(
                    child: PopupDropdownField(
                      label: "Units",
                      hint: "Select Units",
                      value: unit,
                      items: ["Kg", "Gram", "Litre", "Piece"],
                      onChanged: (val) => setState(() => unit = val!),
                    ),
                  ),
                  Flexible(
                    child: PopupDropdownField(
                      label: "Pantry",
                      hint: "Select Pantry",
                      value: pantry,
                      items: context
                          .read<UserCubit>()
                          .state
                          .userStorageAreas
                          .map((area) => area.pantryName)
                          .toList(),
                      onChanged: (val) => setState(() => pantry = val!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: h(15)),
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
                          AppToast.show("Coming soon...", ToastType.info);
                          context.pop();
                        },
                        child: Text(
                          "Edit",
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
                        context.pop();
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

  Widget _formLabel(BuildContext context, String label, {Widget? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: t(15),
            color: Colors.black,
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Future<dynamic> _showDeleteDialog(
    BuildContext context,
    PantryItemEntity pantryItem,
    String kitchenId,
  ) {
    return showCustomGenericDialog(
      context: context,
      title: "Remove Item",
      subtitle: "Are you sure you want to delete this item?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: () {
        context.read<PantryBloc>().add(
          DeleteItemEvent(
            pantry: Pantry(kitchenId: kitchenId, items: [pantryItem]),
          ),
        );
        context.pop();
      },
      onSecondaryPressed: () {
        context.pop();
      },
    );
  }
}
