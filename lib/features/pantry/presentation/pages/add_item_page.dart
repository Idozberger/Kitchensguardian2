import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/core/common/entities/pantry.dart';
import 'package:foodkitchen/core/common/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late PantryBloc pantryBloc;
  late UserCubit userCubit;
  List<PantryItem> _items = [];

  @override
  void initState() {
    pantryBloc = context.read<PantryBloc>();
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
      body: BlocConsumer<PantryBloc, PantryState>(
        listener: (context, state) {
          if (state is PantryFailure) {
            AppToast.show(state.errorMessage, ToastType.error);
            resetState();
          }
          if (state is PantrySuccess) {
            AppToast.show(state.successMessage, ToastType.success);
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

  BlocBuilder<PantryBloc, PantryState> _bottomNavBar() {
    return BlocBuilder<PantryBloc, PantryState>(
      builder: (_, state) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white),
            padding: gapSymmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _addMoreButton(context),
                SizedBox(height: h(22)),
                GenericButtonWidget(
                  isLoading: state is PantryLoading,
                  text: "Add Item",
                  onPressed: state is PantryLoading
                      ? () {}
                      : () {
                          for (final item in _items) {
                            if (item.nameController.text.trim().isEmpty ||
                                item.qtyController.text.trim().isEmpty ||
                                (item.unit?.trim().isEmpty ?? true) ||
                                (item.pantry?.trim().isEmpty ?? true)) {
                              AppToast.show(
                                "Please fill all fields before adding.",
                                ToastType.error,
                              );
                              return;
                            }
                          }

                          final List<PantryItemEntity> pantryItems = [];
                          for (final item in _items) {
                            pantryItems.add(
                              PantryItemEntity(
                                name: item.nameController.text.trim(),
                                quantity:
                                    double.tryParse(
                                      item.qtyController.text.trim(),
                                    ) ??
                                    0,
                                unit: item.unit ?? '',
                                group: item.pantry ?? '',
                              ),
                            );
                          }

                          final pantryModel = Pantry(
                            kitchenId: userCubit.state.activeKitchenId,
                            items: pantryItems,
                          );

                          pantryBloc.add(
                            PantryAddItemEvent(pantry: pantryModel),
                          );
                        },
                ),
              ],
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
        SizedBox(height: h(15)),
        Row(
          spacing: w(12),
          children: [
            Flexible(
              child: Column(
                children: [
                  _formLabel(context, "Manufacturing date"),
                  SizedBox(height: h(10)),
                  AppTextField(
                    controller: item.manuFacturingDate,
                    hintText: "Manufacturing date",
                    fillColor: const Color(0xffF9F9F9),
                    isFilled: true,
                    isLabled: false,
                    keyboardType: TextInputType.text,
                    label: "",
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                children: [
                  _formLabel(context, "Expiring date"),
                  SizedBox(height: h(10)),
                  AppTextField(
                    controller: item.expireDate,
                    hintText: "Expiring date",
                    fillColor: const Color(0xffF9F9F9),
                    isFilled: true,
                    isLabled: false,
                    keyboardType: TextInputType.text,
                    label: "",
                  ),
                ],
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
      title: Text("Add Item", style: Theme.of(context).textTheme.headlineLarge),
    );
  }

  Center _addMoreButton(BuildContext context) {
    return Center(
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
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: t(15),
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
