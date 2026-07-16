import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/date_picker/date_picker_service.dart';
import 'package:foodkitchen/core/services/image_picker/image_picker_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';

class ReceiptPantryItemFormTile extends StatelessWidget {
  const ReceiptPantryItemFormTile({
    super.key,
    required this.item,
    required this.isFirstItem,
    required this.userCubit,
    required this.onItemRemoved,
    required this.onFieldChanged,
  });

  final PantryItem item;
  final bool isFirstItem;
  final UserCubit userCubit;
  final VoidCallback onItemRemoved;
  final VoidCallback onFieldChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UpperTile(
          borderColor: item.needsReview ? Colors.orange : null,
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FormLabelRow(
                label: "Item Image",
                action: isFirstItem
                    ? null
                    : CircularIconButton(
                        iconAsset: AppAssets.deleteSvg,
                        onTap: onItemRemoved,
                      ),
              ),
              SizedBox(height: h(10)),
              _ItemImagePicker(item: item, onPicked: onFieldChanged),
              SizedBox(height: h(10)),
              const _FormLabelRow(label: "Item name"),
              SizedBox(height: h(10)),
              AppTextField(
                label: '',
                color: AppColors.apptextFieldStyleTextColor,
                controller: item.nameController,
                hintText: "Enter item name",
                fillColor: const Color(0xffF9F9F9),
                isFilled: true,
                isLabled: false,
              ),
              SizedBox(height: h(15)),
              const _FormLabelRow(label: "Quantity"),
              SizedBox(height: h(10)),
              AppTextField(
                label: '',
                color: AppColors.apptextFieldStyleTextColor,
                controller: item.qtyController,
                hintText: "Enter item quantity",
                fillColor: const Color(0xffF9F9F9),
                isFilled: true,
                keyboardType: TextInputType.number,
                isLabled: false,
              ),
              SizedBox(height: h(15)),
              _DropdownsRow(
                item: item,
                pantryNames: userCubit.state.userStorageAreas
                    .map((storage) => storage.pantryName)
                    .toList(),
                onChanged: onFieldChanged,
              ),
              SizedBox(height: h(15)),
              const _FormLabelRow(label: "Expiring date"),
              SizedBox(height: h(10)),
              _ExpiryDateField(item: item, onPicked: onFieldChanged),
            ],
          ),
        ),
        if (item.needsReview)
          const Positioned(
            top: 6,
            right: 6,
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 20,
            ),
          ),
      ],
    );
  }
}

class _FormLabelRow extends StatelessWidget {
  const _FormLabelRow({required this.label, this.action});

  final String label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
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
        if (action != null) action!,
      ],
    );
  }
}

class _ItemImagePicker extends StatelessWidget {
  const _ItemImagePicker({required this.item, required this.onPicked});

  final PantryItem item;
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          item.file = await ImagePickerService.showImageSourceDialog(context);
          onPicked();
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
            SafeCircleAvatar(
              radius: t(24),
              file: item.file,
              memoryBytes: item.displayBytes,
              backgroundColor: Colors.transparent,
              fallback: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
                child: Icon(Icons.image, color: Colors.white),
              ),
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
}

class _DropdownsRow extends StatelessWidget {
  const _DropdownsRow({
    required this.item,
    required this.pantryNames,
    required this.onChanged,
  });

  final PantryItem item;
  final List<String> pantryNames;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final unitSystem = context.watch<UserCubit>().state.unitSystem;
    return Row(
      spacing: w(12),
      children: [
        Flexible(
          child: PopupDropdownField(
            label: "Units",
            hint: "Select Units",
            value: item.unit,
            items: unitOptions(unitSystem, current: item.unit),
            displayLabel: unitDisplayLabel,
            onChanged: (val) {
              item.unit = val;
              onChanged();
            },
          ),
        ),
        Flexible(
          child: PopupDropdownField(
            label: "Pantry",
            hint: "Select Pantry",
            value: item.pantry,
            items: pantryNames,
            onChanged: (val) {
              item.pantry = val;
              onChanged();
            },
          ),
        ),
      ],
    );
  }
}

class _ExpiryDateField extends StatelessWidget {
  const _ExpiryDateField({required this.item, required this.onPicked});

  final PantryItem item;
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await DatePickerService.pickDate(context: context);
        if (pickedDate != null) {
          item.expireDate.text = pickedDate;
          onPicked();
        }
      },
      child: AppTextField(
        enabled: false,
        suffixIcon: Icon(
          Icons.date_range,
          color: AppColors.appTextFieldBorderColor,
        ),
        color: AppColors.apptextFieldStyleTextColor,
        controller: item.expireDate,
        hintText: "Expiring date",
        fillColor: const Color(0xffF9F9F9),
        isFilled: true,
        isLabled: false,
        label: '',
      ),
    );
  }
}
