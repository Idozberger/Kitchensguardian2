import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';

class AddCustomItemsPage extends StatefulWidget {
  const AddCustomItemsPage({super.key});

  @override
  State<AddCustomItemsPage> createState() => _AddCustomItemsPageState();
}

class _AddCustomItemsPageState extends State<AddCustomItemsPage> {
  late GroceryBloc groceryBloc;
  late UserCubit userCubit;
  List<PantryItem> _items = [];

  @override
  void initState() {
    groceryBloc = context.read<GroceryBloc>();
    userCubit = context.read<UserCubit>();

    super.initState();
    _addNewItem();
  }

  void _addNewItem() {
    setState(() {
      _items.add(
        PantryItem(
          nameController: TextEditingController(),
          qtyController: TextEditingController(),
          expireDate: TextEditingController(),
          manuFacturingDate: TextEditingController(),
        ),
      );
    });
  }

  void resetState() {
    setState(() {
      _items = [];
      _addNewItem();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocConsumer<GroceryBloc, GroceryState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppToast.show(state.errorMessage!, ToastType.error);
            resetState();
          }
          if (state.successMessage != null) {
            AppToast.show(state.successMessage!, ToastType.success);
            resetState();
          }
        },
        builder: (_, state) {
          return SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 0),
              child: Column(
                children: [
                  gap(height: 14),
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
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: _bottomNavBar(),
    );
  }

  BlocBuilder<GroceryBloc, GroceryState> _bottomNavBar() {
    return BlocBuilder<GroceryBloc, GroceryState>(
      builder: (_, state) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white),
            padding: gapSymmetric(horizontal: 20, vertical: 10),
            child: GenericButtonWidget(
              isLoading: state.isLoading,
              text: "Add Item",
              onPressed: state.isLoading
                  ? () {}
                  : () {
                      if (_items[0].nameController.text.trim().isEmpty ||
                          _items[0].qtyController.text.trim().isEmpty ||
                          (_items[0].unit?.trim().isEmpty ?? true)) {
                        AppToast.show(
                          "Please fill all fields before adding.",
                          ToastType.error,
                        );
                      } else {
                        groceryBloc.add(
                          AddCustomItemEvent(
                            kitchenId: userCubit.state.activeKitchenId,
                            bucketype: 'mylist',
                            name: _items[0].nameController.text,
                            quantity: _items[0].qtyController.text,
                            unit: _items[0].unit ?? "",
                          ),
                        );
                      }
                    },
            ),
          ),
        );
      },
    );
  }

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
                  decoration: BoxDecoration(shape: BoxShape.circle),
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
          controller: item.qtyController,
          hintText: "Enter item quantity",
          fillColor: const Color(0xffF9F9F9),
          isFilled: true,
          isLabled: false,
          keyboardType: TextInputType.text,
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
                items: ["Kg", "Gram", "Litre", "Piece"],
                onChanged: (val) => setState(() => item.unit = val),
              ),
            ),
            // Flexible(
            //   child: PopupDropdownField(
            //     label: "Pantry",
            //     hint: "Select Pantry",
            //     value: item.pantry,
            //     items: [
            //       "Fridge",
            //       "Freezer",
            //       "Shelves",
            //       "Cabinets",
            //       "Drawers",
            //       "Cold cellar",
            //       "Butler's Pantry",
            //     ],
            //     onChanged: (val) => setState(() => item.pantry = val),
            //   ),
            // ),
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
      centerTitle: true,
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "Add Custom Item",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
