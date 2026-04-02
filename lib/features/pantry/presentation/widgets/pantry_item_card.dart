import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/date_picker/date_picker_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:go_router/go_router.dart';

class PantryItemCard extends StatefulWidget {
  final Uint8List thumbnail;
  final String title;
  final String quantity;
  final String unit;
  final String pantry;
  final VoidCallback onListCheckedCallback;
  final VoidCallback onCartItem;
  final String expiry;
  final PantryItemEntity pantryItemEntity;
  final String kitchenId;
  final bool isLocked;

  const PantryItemCard({
    super.key,
    required this.title,
    required this.quantity,
    required this.thumbnail,
    required this.unit,
    required this.pantry,
    required this.expiry,
    required this.onListCheckedCallback,
    required this.onCartItem,
    required this.pantryItemEntity,
    required this.kitchenId,
    required this.isLocked,
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
        if (widget.isLocked) {
          context.push(Routes.subscription);
        } else {
          setState(() => _isExpanded = !_isExpanded);
        }
        FocusScope.of(context).unfocus();
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
            SizedBox(height: h(1)),
            if (!widget.isLocked) ...[
              if (widget.pantryItemEntity.expiryStatus == "expiring_soon" ||
                  widget.pantryItemEntity.stockStatus == "low_stock")
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(height: h(1), width: double.maxFinite),
                    Positioned(
                      top: -h(22),
                      right:
                          widget.pantryItemEntity.expiryStatus ==
                                  "expiring_soon" &&
                              widget.pantryItemEntity.stockStatus == "low_stock"
                          ? w(134)
                          : widget.pantryItemEntity.stockStatus ==
                                    "low_stock" &&
                                widget.pantryItemEntity.expiryStatus !=
                                    "expiring_soon"
                          ? w(54)
                          : w(62),
                      child: Badge(
                        label: Padding(
                          padding: gapAll(2),
                          child: Text(
                            widget.pantryItemEntity.expiryStatus ==
                                        "expiring_soon" &&
                                    widget.pantryItemEntity.stockStatus ==
                                        "low_stock"
                                ? "Expiring soon and low-stock"
                                : widget.pantryItemEntity.expiryStatus ==
                                      "expiring_soon"
                                ? "Expiring soon"
                                : "Running low",
                          ),
                        ),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(h(24)),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: widget.isLocked ? 6 : 0,
                          sigmaY: widget.isLocked ? 6 : 0,
                        ),
                        child: Image.memory(
                          widget.thumbnail,
                          height: h(28),
                          width: h(28),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: h(28),
                              width: h(28),
                              alignment: Alignment.center,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.food_bank,
                                size: h(16),
                                color: Colors.grey.shade500,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gap(width: 8),
                    SizedBox(
                      width: _isExpanded ? w(244) : w(54),
                      child: widget.isLocked
                          ? ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 5,
                                sigmaY: 5,
                              ),
                              child: Text(
                                widget.title,
                                maxLines: _isExpanded ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                            )
                          : Text(
                              widget.title,
                              maxLines: _isExpanded ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                    ),
                    if (!_isExpanded) ...[
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: widget.isLocked ? 5 : 0,
                          sigmaY: widget.isLocked ? 5 : 0,
                        ),
                        child: Opacity(
                          opacity: widget.isLocked ? 0.5 : 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: w(38),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: _buildInlineInfo(widget.quantity),
                                ),
                              ),
                              SizedBox(width: w(24), child: _dot()),

                              SizedBox(
                                width: w(38),
                                child: _buildInlineInfo(widget.unit),
                              ),
                              SizedBox(width: w(24), child: _dot()),

                              SizedBox(
                                width: w(54),
                                child: _buildInlineInfo(widget.pantry),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: widget.isLocked ? 4 : 0,
                      sigmaY: widget.isLocked ? 4 : 0,
                    ),
                    child: SvgPicture.asset(AppAssets.downArrow),
                  ),
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
            if (widget.isLocked) _buildBlurOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurOverlay() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(height: 10),

        Positioned(
          top: -h(34),
          left: w(62),

          child: Container(
            padding: gapAll(12),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              borderRadius: BorderRadius.circular(t(100)),
            ),
            child: Row(
              spacing: w(12),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppAssets.crownImage, height: h(24)),
                Text(
                  "Upgrade to Premium",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: t(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: t(14),
          color: const Color(0xff787878),
          fontWeight: FontWeight.w400,
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
        return StatefulBuilder(
          builder: (context, setState) {
            return GenericDialog(
              borderRadius: h(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formLabel(context, "Item name"),
                  SizedBox(height: h(10)),

                  AppTextField(
                    isLabled: false,
                    controller: itemName,
                    hintText: "Enter item name",
                    textInputAction: TextInputAction.next,
                    color: AppColors.apptextFieldStyleTextColor,
                    fillColor: const Color(0xffF9F9F9),
                    isFilled: true,
                    label: '',
                  ),

                  SizedBox(height: h(15)),
                  _formLabel(context, "Quantity"),
                  SizedBox(height: h(10)),

                  AppTextField(
                    isLabled: false,
                    controller: quantity,
                    hintText: "Enter item quantity",
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    color: AppColors.apptextFieldStyleTextColor,
                    fillColor: const Color(0xffF9F9F9),
                    isFilled: true,
                    label: '',
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
                          items: [
                            "Kg",
                            "Gram",
                            "Litre",
                            "Piece",
                            "Milliliters",
                          ],
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
                  _buildDatePicker(expireDate),
                  SizedBox(height: h(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: SizedBox(
                          height: h(40),
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              final updatedItem = PantryItemEntity(
                                itemId: pantryItem.itemId,
                                name: itemName.text.trim(),
                                quantity: double.tryParse(quantity.text) ?? 0,
                                unit: unit,
                                group: pantry,
                                expireDate: expireDate.text,
                                thumbnail:
                                    "data:image/jpeg;base64,${base64Encode(pantryItem.thumbnailBytes!)}",
                                expiryStatus: pantryItem.expiryStatus,
                                stockStatus: pantryItem.stockStatus,
                              );

                              final pantryUpdate = Pantry(
                                kitchenId: kitchenId,
                                items: [updatedItem],
                              );

                              context.read<PantryBloc>().add(
                                UpdateItemEvent(pantry: pantryUpdate),
                              );

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
                          onPressed: () => context.pop(),
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
      },
    );
  }

  Widget _buildDatePicker(TextEditingController expireDate) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await DatePickerService.updateExpireDate(
          context: context,
          selectedDateString: expireDate.text,
        );
        if (pickedDate != null) {
          setState(() => expireDate.text = pickedDate);
        }
      },
      child: AppTextField(
        textInputAction: TextInputAction.next,
        enabled: false,
        color: AppColors.apptextFieldStyleTextColor,
        controller: expireDate,
        hintText: "Expiring date",
        fillColor: const Color(0xFFF9F9F9),
        isFilled: true,
        isLabled: false,
        keyboardType: TextInputType.text,
        label: '',
      ),
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
