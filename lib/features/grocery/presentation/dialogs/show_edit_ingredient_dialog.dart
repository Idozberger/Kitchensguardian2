import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';

void showEditItemDialog(
  BuildContext context, {
  required String kitchenId,
  required String itemId,
  required String initialName,
  required String initialQuantity,
  required String initialUnit,
  required GroceryBloc groceryBloc,
}) {
  final nameController = TextEditingController(text: initialName);
  final quantityController = TextEditingController(text: initialQuantity);

  showDialog(
    context: context,
    builder: (_) => BlocProvider.value(
      value: groceryBloc,
      child: _EditItemDialog(
        kitchenId: kitchenId,
        itemId: itemId,
        nameController: nameController,
        quantityController: quantityController,
        initialUnit: initialUnit,
      ),
    ),
  );
}

class _EditItemDialog extends StatefulWidget {
  final String kitchenId;
  final String itemId;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final String initialUnit;

  const _EditItemDialog({
    required this.kitchenId,
    required this.itemId,
    required this.nameController,
    required this.quantityController,
    required this.initialUnit,
  });

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  static const _unitOptions = ["Kg", "Gram", "Litre", "Piece", "Milliliters"];

  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.initialUnit;
  }

  void _onSave() {
    context.read<GroceryBloc>().add(
      EditGroceryListItemEvent(
        kitchenId: widget.kitchenId,
        itemId: widget.itemId,
        name: widget.nameController.text.trim(),
        quantity: widget.quantityController.text.trim(),
        unit: _selectedUnit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroceryBloc, GroceryState>(
      listener: (context, state) {
        // Close dialog once editing is done successfully
        if (!state.editingGroceryItem && state.errorMessage == null) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return GenericDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Item",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(20),
                ),
              ),
              SizedBox(height: h(16)),
              _buildFormLabel("Ingredient Name"),
              SizedBox(height: h(10)),
              AppTextField(
                isLabled: false,
                label: '',
                hintText: "e.g. Tomatoes",
                controller: widget.nameController,
              ),
              SizedBox(height: h(12)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildFormLabel("Quantity"),
                        SizedBox(height: h(10)),
                        AppTextField(
                          isLabled: false,
                          label: '',
                          hintText: "e.g. 2",
                          controller: widget.quantityController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: w(12)),
                  Flexible(
                    child: PopupDropdownField(
                      label: "Units",
                      hint: "Select Units",
                      value: _selectedUnit,
                      items: _unitOptions,
                      onChanged: (val) =>
                          setState(() => _selectedUnit = val ?? _selectedUnit),
                    ),
                  ),
                ],
              ),
              SizedBox(height: h(20)),
              Row(
                children: [
                  Expanded(
                    child: GenericButtonWidget(
                      text: "Cancel",
                      isOutlined: true,
                      isDisabled: state.editingGroceryItem,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  SizedBox(width: w(12)),
                  Expanded(
                    child: GenericButtonWidget(
                      text: "Save",
                      isLoading: state.editingGroceryItem,

                      onPressed: _onSave,
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

  Widget _buildFormLabel(String label, {Widget? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: t(15),
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (action != null) action,
      ],
    );
  }
}
