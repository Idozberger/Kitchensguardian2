import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item/add_item_page_chrome.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_kitchen_pantry/add_kitchen_pantry_item_form.dart';

class AddKitchenPantryPage extends StatefulWidget {
  const AddKitchenPantryPage({super.key});

  @override
  State<AddKitchenPantryPage> createState() => _AddKitchenPantryPageState();
}

class _AddKitchenPantryPageState extends State<AddKitchenPantryPage> {
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
    for (final item in _items) {
      if (validateAddKitchenPantryItem(item) != null) {
        return;
      }
    }
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

  void _submitItems() {
    for (final item in _items) {
      if (validateAddKitchenPantryItem(item) != null) {
        return;
      }
    }

    final List<PantryItemEntity> pantryItems = [];
    for (final item in _items) {
      pantryItems.add(
        PantryItemEntity(
          name: item.nameController.text.trim(),
          quantity: double.tryParse(item.qtyController.text.trim()) ?? 0,
          unit: item.unit ?? '',
          group: item.pantry ?? '',
          expireDate: item.expireDate.text,
          thumbnail: "",
          expiryStatus: '',
          stockStatus: '',
          itemId: '',
        ),
      );
    }

    final pantryModel = Pantry(
      kitchenId: userCubit.state.activeKitchenId,
      items: pantryItems,
    );

    pantryBloc.add(PantryAddItemEvent(pantry: pantryModel, isMember: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AddItemPageAppBar(
        isMember: false,
        titleOverride: "Add Item",
        onBack: () => Navigator.pop(context),
      ),
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
                            widget: AddKitchenPantryItemForm(
                              item: item,
                              isFirstItem: _items.first == item,
                              updateState: setState,
                              onRemove: () {
                                _items.remove(item);
                                setState(() {});
                              },
                            ),
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
      bottomNavigationBar: PantryItemSubmitFooter(
        showAddMore: true,
        submitLabel: "Add Item",
        onAddMore: _addNewItem,
        onSubmit: _submitItems,
        isSubmitting: (s) => s is PantryLoading,
      ),
    );
  }
}
