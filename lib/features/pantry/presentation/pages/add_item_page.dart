import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

/// Data model for Pantry Item
class PantryItem {
  final TextEditingController nameController;
  final TextEditingController qtyController;
  String? unit;
  String? pantry;

  PantryItem({
    required this.nameController,
    required this.qtyController,
    this.unit,
    this.pantry,
  });
}

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final List<PantryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _addNewItem();
  }

  void _addNewItem() {
    setState(() {
      _items.add(
        PantryItem(
          nameController: TextEditingController(),
          qtyController: TextEditingController(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: gapZero,
                  shrinkWrap: true,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: gapOnly(bottom: 10),
                      child: UpperTile(
                        widget: _buildPantryItemForm(context, item),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: h(22)),

              /// Add more button
              Center(
                child: SizedBox(
                  width: w(188),
                  height: h(40),
                  child: OutlinedButton.icon(
                    onPressed: _addNewItem,
                    icon: SvgPicture.asset(
                      AppAssets.addSvg,
                      color: AppColors.primaryColor,
                      width: w(18),
                      height: h(18),
                    ),
                    label: Text(
                      "Tap to add more",
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            fontSize: t(15),
                            color: AppColors.primaryColor,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GenericButtonWidget(
                text: "Save Edit",
                onPressed: () {
                  for (var item in _items) {
                    debugPrint(
                      "Name: ${item.nameController.text}, "
                      "Qty: ${item.qtyController.text}, "
                      "Unit: ${item.unit}, "
                      "Pantry: ${item.pantry}",
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds form fields for each Pantry item
  Widget _buildPantryItemForm(BuildContext context, PantryItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel(
          context,
          "Item name",
          action: _items.first == item
              ? null
              : Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyColor),
                    shape: BoxShape.circle,
                  ),
                  child: CircularIconButton(
                    iconAsset: AppAssets.deleteSvg,
                    onTap: () {
                      _items.remove(item);
                      setState(() {});
                    },
                  ),
                ),
        ),
        SizedBox(height: h(10)),
        AppTextField(
          controller: item.nameController,
          hintText: "Enter item quantity",
          fillColor: const Color(0xffF9F9F9),
          isFilled: true,
          isLabled: false,
          keyboardType: TextInputType.number,
          label: "",
        ),
        SizedBox(height: h(15)),
        Row(
          spacing: w(12),
          children: [
            pantryItemTile(
              label: "Quantity",
              child: AppTextField(
                controller: item.qtyController,
                hintText: "0",
                keyboardType: TextInputType.number,
                fillColor: const Color(0xffF9F9F9),
                color: const Color(0xff787878),
                isFilled: true,
                isLabled: false,
                label: "",
              ),
            ),
            Flexible(
              child: PopupDropdownField(
                label: "Units",
                hint: "Select Units",
                value: item.unit,
                items: ["Kg", "Gram", "Litre", "Piece"],
                onChanged: (val) => setState(() => item.unit = val),
              ),
            ),
            Flexible(
              child: PopupDropdownField(
                label: "Pantry",
                hint: "Select Pantry",
                value: item.pantry,
                items: [
                  "Fridge",
                  "Freezer",
                  "Shelves",
                  "Cabinets",
                  "Drawers",
                  "Cold cellar",
                  "Butler's Pantry",
                ],
                onChanged: (val) => setState(() => item.pantry = val),
              ),
            ),
          ],
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

  InputDecoration _dropdownDecoration(BuildContext context) {
    return InputDecoration(
      contentPadding: gapSymmetric(horizontal: 8, vertical: 15),
      border: outlineInputBorder(context),
      enabledBorder: outlineInputBorder(context),
      focusedBorder: outlineInputBorder(context),
      errorBorder: outlineInputBorder(
        context,
      ).copyWith(borderSide: BorderSide(color: AppColors.errorColor)),
      filled: true,
      fillColor: const Color(0xffF9F9F9),
    );
  }

  TextStyle? _dropdownTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontSize: t(15),
      color: const Color(0xff787878),
    );
  }

  Widget pantryItemTile({required String label, required Widget child}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _formLabel(context, label),
          SizedBox(height: h(10)),
          child,
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text("Add Item", style: Theme.of(context).textTheme.headlineLarge),
    );
  }
}
