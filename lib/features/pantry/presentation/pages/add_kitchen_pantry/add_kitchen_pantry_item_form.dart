import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/date_picker/date_picker_service.dart'
    show DatePickerService;
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item/add_item_pantry_item_form.dart';

/// Default storage labels for onboarding / add-kitchen pantry flow.
const List<String> kAddKitchenPantryAreaOptions = [
  "Fridge",
  "Freezer",
  "Shelves",
  "Cabinets",
  "Drawers",
  "Cold cellar",
  "Butler's Pantry",
];

String? validateAddKitchenPantryItem(PantryItem item) {
  final name = item.nameController.text.trim();
  final qty = item.qtyController.text.trim();
  final unit = item.unit?.trim() ?? '';
  final pantry = item.pantry?.trim() ?? '';
  final expireDate = item.expireDate.text.trim();

  if (name.isEmpty) {
    AppToast.show("Please enter the item name.", ToastType.error);
    return "name";
  }
  if (name.length < 3) {
    AppToast.show(
      "Item name must be at least 3 characters long.",
      ToastType.error,
    );
    return "name_len";
  }
  if (qty.isEmpty) {
    AppToast.show("Please enter the quantity.", ToastType.error);
    return "qty";
  }
  if (unit.isEmpty) {
    AppToast.show("Please select a unit.", ToastType.error);
    return "unit";
  }
  if (pantry.isEmpty) {
    AppToast.show("Please select a pantry.", ToastType.error);
    return "pantry";
  }
  if (expireDate.isEmpty) {
    AppToast.show("Please select an expiry date.", ToastType.error);
    return "expiry";
  }
  return null;
}

class AddKitchenPantryItemForm extends StatelessWidget {
  const AddKitchenPantryItemForm({
    super.key,
    required this.item,
    required this.isFirstItem,
    required this.updateState,
    required this.onRemove,
  });

  final PantryItem item;
  final bool isFirstItem;
  final AddItemPageSetState updateState;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final unitSystem = context.watch<UserCubit>().state.unitSystem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel(
          context,
          "Item name",
          action: isFirstItem
              ? null
              : Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: CircularIconButton(
                    iconAsset: AppAssets.deleteSvg,
                    onTap: onRemove,
                  ),
                ),
        ),
        SizedBox(height: h(10)),
        AppTextField(
          color: AppColors.apptextFieldStyleTextColor,
          controller: item.nameController,
          hintText: "Enter item name",
          fillColor: const Color(0xffF9F9F9),
          isFilled: true,
          isLabled: false,
          keyboardType: TextInputType.text,
          label: "",
        ),
        SizedBox(height: h(15)),
        _formLabel(context, "Quantity"),
        SizedBox(height: h(10)),
        AppTextField(
          color: AppColors.apptextFieldStyleTextColor,
          controller: item.qtyController,
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
                value: item.unit,
                items: unitOptions(unitSystem, current: item.unit),
                displayLabel: unitDisplayLabel,
                onChanged: (val) => updateState(() => item.unit = val),
              ),
            ),
            Flexible(
              child: PopupDropdownField(
                label: "Pantry",
                hint: "Select Pantry",
                value: item.pantry,
                items: kAddKitchenPantryAreaOptions,
                onChanged: (val) => updateState(() => item.pantry = val),
              ),
            ),
          ],
        ),
        SizedBox(height: h(15)),
        _formLabel(context, "Expiring date"),
        SizedBox(height: h(10)),
        GestureDetector(
          onTap: () async {
            final pickedDate = await DatePickerService.pickDate(
              context: context,
            );
            if (pickedDate != null) {
              updateState(() => item.expireDate.text = pickedDate);
            }
          },
          child: AppTextField(
            enabled: false,
            color: AppColors.apptextFieldStyleTextColor,
            controller: item.expireDate,
            hintText: "Expiring date",
            fillColor: const Color(0xffF9F9F9),
            isFilled: true,
            isLabled: false,
            keyboardType: TextInputType.text,
            label: "",
          ),
        ),
      ],
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
}
