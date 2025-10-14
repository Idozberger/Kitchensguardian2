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
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/domain/entities/pantry.dart';
import 'package:foodkitchen/features/pantry/domain/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';

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
        ),
      );
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
          }
          if (state is PantrySuccess) {
            AppToast.show(state.successMessage, ToastType.success);
          }
        },
        builder: (_, state) {
          return SafeArea(
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
          );
        },
      ),

      bottomNavigationBar: BlocBuilder<PantryBloc, PantryState>(
        builder: (_, state) {
          return SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GenericButtonWidget(
                    isLoading: state is PantryLoading,
                    text: "Add Item",
                    onPressed: () {
                      final List<PantryItemEntity> pantryItems = _items.map((
                        item,
                      ) {
                        return PantryItemEntity(
                          name: item.nameController.text.trim(),
                          quantity:
                              double.tryParse(item.qtyController.text.trim()) ??
                              0,
                          unit: item.unit ?? '',
                          group: item.pantry ?? '',
                        );
                      }).toList();

                      final pantryModel = Pantry(
                        kitchenId: userCubit.state.activeKitchenId,
                        items: pantryItems,
                      );

                      for (var item in pantryItems) {
                        debugPrint(
                          "Name: ${item.name}, Qty: ${item.quantity}, Unit: ${item.unit}, Group: ${item.group}",
                        );
                      }

                      pantryBloc.add(PantryAddItemEvent(pantry: pantryModel));
                      setState(() {
                        _items = [];
                        _addNewItem();
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
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
          hintText: "Enter item name",
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
