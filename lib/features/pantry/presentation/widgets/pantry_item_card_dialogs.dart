import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/date_picker/date_picker_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:go_router/go_router.dart';

Future<dynamic> showPantryItemEditDialog(
  BuildContext context,
  PantryItemEntity pantryItem,
  String kitchenId,
) {
  final TextEditingController itemName = TextEditingController(
    text: pantryItem.name,
  );

  final TextEditingController quantity = TextEditingController(
    text: formatQuantity(pantryItem.quantity, grouped: false),
  );

  String unit = pantryItem.unit;
  String pantry = pantryItem.group;

  final TextEditingController expireDate = TextEditingController(
    text: pantryItem.expireDate,
  );

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
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
                        items: unitOptions(
                          context.read<UserCubit>().state.unitSystem,
                          current: unit,
                        ),
                        displayLabel: unitDisplayLabel,
                        onChanged: (val) => setDialogState(() => unit = val!),
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
                        onChanged: (val) => setDialogState(() => pantry = val!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h(15)),
                _buildDatePickerField(context, expireDate, setDialogState),
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
                            final thumb = pantryItem.thumbnailBytes;
                            final updatedItem = PantryItemEntity(
                              itemId: pantryItem.itemId,
                              name: itemName.text.trim(),
                              quantity: double.tryParse(quantity.text) ?? 0,
                              unit: unit,
                              group: pantry,
                              expireDate: expireDate.text,
                              thumbnail: thumb != null && thumb.isNotEmpty
                                  ? "data:image/jpeg;base64,${base64Encode(thumb)}"
                                  : pantryItem.thumbnail,
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

                            dialogContext.pop();
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
                        onPressed: () => dialogContext.pop(),
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

Widget _buildDatePickerField(
  BuildContext context,
  TextEditingController expireDate,
  void Function(void Function()) setDialogState,
) {
  return GestureDetector(
    onTap: () async {
      final pickedDate = await DatePickerService.updateExpireDate(
        context: context,
        selectedDateString: expireDate.text,
      );
      if (pickedDate != null) {
        setDialogState(() => expireDate.text = pickedDate);
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

Future<dynamic> showPantryItemDeleteDialog(
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
