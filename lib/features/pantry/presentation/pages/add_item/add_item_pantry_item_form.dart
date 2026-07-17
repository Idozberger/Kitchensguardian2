import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/date_picker/date_picker_service.dart';
import 'package:foodkitchen/core/services/image_picker/image_picker_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item/item_name_search_field.dart';

typedef AddItemPageSetState = void Function(VoidCallback fn);

class AddItemPantryItemForm extends StatelessWidget {
  const AddItemPantryItemForm({
    super.key,
    required this.item,
    required this.userState,
    required this.isMember,
    required this.isFirstItem,
    required this.updateState,
    required this.onRemove,
  });

  final PantryItem item;
  final UserState userState;
  final bool isMember;
  final bool isFirstItem;
  final AddItemPageSetState updateState;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel(
          context,
          "Item Image",
          action: isFirstItem
              ? null
              : CircularIconButton(
                  iconAsset: AppAssets.deleteSvg,
                  onTap: onRemove,
                ),
        ),
        SizedBox(height: h(10)),
        _imagePicker(context),
        SizedBox(height: h(10)),
        _formLabel(context, "Item name"),
        SizedBox(height: h(10)),
        ItemNameSearchField(
          controller: item.nameController,
          onCatalogIdChanged: (id) =>
              updateState(() => item.sharedIngredientId = id),
        ),
        SizedBox(height: h(15)),
        _formLabel(context, "Quantity"),
        SizedBox(height: h(10)),
        AppTextField(
          suffixIcon: Platform.isAndroid
              ? null
              : IconButton(
                  onPressed: () => FocusScope.of(context).unfocus(),
                  icon: Icon(Icons.done, color: Colors.grey),
                ),
          textInputAction: TextInputAction.done,
          color: AppColors.apptextFieldStyleTextColor,
          controller: item.qtyController,
          hintText: "Enter item quantity",
          fillColor: const Color(0xFFF9F9F9),
          isFilled: true,
          keyboardType: TextInputType.number,
          isLabled: false,
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
                value: item.unit,
                items: unitOptions(userState.unitSystem, current: item.unit),
                displayLabel: unitDisplayLabel,
                onChanged: (val) => updateState(() {
                  item.unit = val;
                  item.needsReview = false;
                }),
              ),
            ),
            if (isMember == false)
              Flexible(
                child: PopupDropdownField(
                  label: "Pantry",
                  hint: "Select Pantry",
                  value: item.pantry,
                  items: userState.userStorageAreas
                      .map((area) => area.pantryName)
                      .toList(),
                  onChanged: (val) => updateState(() {
                    item.pantry = val;
                    item.needsReview = false;
                  }),
                ),
              ),
          ],
        ),
        if (isMember == false) SizedBox(height: h(15)),
        if (isMember == false) _formLabel(context, "Expiring date"),
        if (isMember == false) SizedBox(height: h(10)),
        if (isMember == false) _datePicker(context),
      ],
    );
  }

  Widget _imagePicker(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          item.file = await ImagePickerService.showImageSourceDialog(context);
          updateState(() => item.needsReview = false);
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: t(24),
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person, color: Colors.grey, size: t(24)),
            ),
            if (item.file != null)
              SafeCircleAvatar(
                radius: t(24),
                file: item.file,
                backgroundColor: Colors.transparent,
                fallback: const SizedBox.shrink(),
              ),
            Positioned(
              bottom: h(-2),
              right: w(-4),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: gapAll(4),
                child: CircleAvatar(
                  radius: t(8),
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.add, size: t(12), color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await DatePickerService.pickDate(context: context);
        if (pickedDate != null) {
          updateState(() {
            item.expireDate.text = pickedDate;
            item.needsReview = false;
          });
        }
      },
      child: AppTextField(
        textInputAction: TextInputAction.next,
        enabled: false,
        color: AppColors.apptextFieldStyleTextColor,
        controller: item.expireDate,
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
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (action != null) action,
      ],
    );
  }
}
