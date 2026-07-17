import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/format_date_for_backend.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item/add_item_page_chrome.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item/add_item_pantry_item_form.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:go_router/go_router.dart';

part 'add_item_page_part.dart';

class AddItemPage extends StatefulWidget {
  final List<PantryItem> pantryItems;
  final bool addToInventory;
  final bool isMember;
  final String recipeId;
  final List<IngredientEntity> selectedIngredients;
  const AddItemPage({
    super.key,
    this.pantryItems = const [],
    this.addToInventory = false,
    this.isMember = false,
    this.recipeId = "",
    this.selectedIngredients = const [],
  });

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late PantryBloc _pantryBloc;
  late UserCubit _userCubit;
  List<PantryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _pantryBloc = context.read<PantryBloc>();
    _userCubit = context.read<UserCubit>();
    _addNewItem();
  }

  void _addNewItem() {
    setState(() {
      if (widget.pantryItems.isNotEmpty) {
        _items = widget.pantryItems;
      } else {
        _items.add(
          PantryItem(
            nameController: TextEditingController(),
            qtyController: TextEditingController(),
            expireDate: TextEditingController(),
            manuFacturingDate: TextEditingController(),
          ),
        );
      }
    });
  }

  void _resetState() {
    setState(() {
      _items = [];
      if (widget.addToInventory) {
        context.read<PlannerBloc>().add(
          RemoveMissingIngredientEvent(
            selectedIngredients: widget.selectedIngredients,
            recipeId: widget.recipeId,
          ),
        );
        context.read<PlannerBloc>().add(
          RemoveMissingIngredientFromPlanEvent(
            selectedIngredients: widget.selectedIngredients,
            recipeId: widget.recipeId,
          ),
        );
        _items.add(
          PantryItem(
            nameController: TextEditingController(),
            qtyController: TextEditingController(),
            expireDate: TextEditingController(),
            manuFacturingDate: TextEditingController(),
          ),
        );
      } else {
        _addNewItem();
      }
    });

    if (widget.addToInventory) {
      context.read<PlannerBloc>().add(
        GetAllWeeklyPlansEvent(
          context.read<UserCubit>().state.activeKitchenId,
          null,
        ),
      );
      context.read<HomeBloc>().add(GetAllWeeklyPlansEventForHome());
    }
  }

  @override
  Widget build(BuildContext context) {
    devLog("isMember-- ${widget.isMember}");
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await Future<void>.delayed(Duration.zero);
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AddItemPageAppBar(
          isMember: widget.isMember,
          onBack: _handleBackNavigation,
        ),
        body: BlocConsumer<PantryBloc, PantryState>(
          listener: (context, state) {
            if (state is PantryFailure) {
              AppToast.show(state.errorMessage, ToastType.error);
              _resetState();
            } else if (state is PantrySuccess) {
              AppToast.show(state.successMessage, ToastType.success);
              _resetState();
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: gapSymmetric(horizontal: 20, vertical: 0),
                child: Column(
                  children: [
                    gap(height: 14),
                    Expanded(
                      child: BlocBuilder<UserCubit, UserState>(
                        builder: (context, userState) {
                          return ListView.builder(
                            padding: gapZero,
                            shrinkWrap: true,
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Padding(
                                padding: gapOnly(bottom: 12),
                                child: UpperTile(
                                  widget: AddItemPantryItemForm(
                                    item: item,
                                    userState: userState,
                                    isMember: widget.isMember,
                                    isFirstItem: _items.first == item,
                                    updateState: setState,
                                    onRemove: () =>
                                        setState(() => _items.remove(item)),
                                  ),
                                ),
                              );
                            },
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
        bottomNavigationBar: AddItemPageBottomBar(
          showAddMore: widget.addToInventory == false,
          isMember: widget.isMember,
          onAddMore: _addNewItem,
          onSubmit: _handleSubmitItems,
        ),
      ),
    );
  }

  Future<void> _handleSubmitItems() async {
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final validation = addItemPageValidateRow(item);
      if (validation != null) {
        AppToast.show(validation, ToastType.error);
        return;
      }
    }

    final pantryItems = <PantryItemEntity>[];
    for (final item in _items) {
      final compressedImage = await addItemPageCompressImage(item.file);
      pantryItems.add(
        PantryItemEntity(
          name: item.nameController.text.trim(),
          quantity: double.tryParse(item.qtyController.text.trim()) ?? 0,
          unit: item.unit ?? "",
          group: item.pantry ?? "",
          expireDate: formatExpiry(item.expireDate.text),
          thumbnail: compressedImage,
          expiryStatus: '',
          stockStatus: '',
          itemId: '',
          sharedIngredientId: item.sharedIngredientId,
        ),
      );
    }

    final pantryModel = Pantry(
      kitchenId: _userCubit.state.activeKitchenId,
      items: pantryItems,
    );

    _pantryBloc.add(
      PantryAddItemEvent(pantry: pantryModel, isMember: widget.isMember),
    );
  }

  void _handleBackNavigation() {
    if (_items.isEmpty) {
      _goBack();
      return;
    }

    final hasUserInput = _items.any(
      (item) =>
          item.file != null ||
          item.nameController.text.trim().isNotEmpty ||
          item.qtyController.text.trim().isNotEmpty ||
          (item.unit != null && item.unit!.isNotEmpty) ||
          (item.pantry != null && item.pantry!.isNotEmpty) ||
          item.expireDate.text.isNotEmpty,
    );

    if (hasUserInput) {
      _showConfirmDialog(
        title: "Go Back",
        subtitle:
            "If you go back, the items you just added will be removed. Continue?",
        onConfirm: () {
          Navigator.of(context).pop();
          _goBack();
        },
      );
    } else {
      _goBack();
    }
  }

  void _goBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);
      if (router.canPop()) {
        router.pop();
      }
    });
  }

  Future<void> _showConfirmDialog({
    required String title,
    required String subtitle,
    required VoidCallback onConfirm,
  }) {
    return showCustomGenericDialog(
      context: context,
      title: title,
      subtitle: subtitle,
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: () => context.pop(),
    );
  }
}
