import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/date_picker/date_picker_service.dart';
import 'package:foodkitchen/core/services/image_picker/image_picker_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/format_date_for_backend.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:go_router/go_router.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    log("isMember-- ${widget.isMember}");
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await Future.delayed(Duration.zero);
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: _buildAppBar(),
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
                                  widget: _buildPantryItemForm(
                                    context,
                                    item,
                                    userState,
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
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BlocBuilder<PantryBloc, PantryState>(
      builder: (context, state) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
            padding: gapOnly(left: 20, right: 20, bottom: 14, top: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAddMoreButton(),
                SizedBox(height: h(22)),
                GenericButtonWidget(
                  isLoading: state is SubmittingItemLoading,
                  text: widget.isMember ? "Request Item" : "Add Item",
                  onPressed: state is SubmittingItemLoading
                      ? () {}
                      : () => _handleSubmitItems(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmitItems() async {
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final validation = _validateItem(item);
      if (validation != null) {
        AppToast.show(validation, ToastType.error);
        return;
      }
    }

    final pantryItems = <PantryItemEntity>[];
    for (final item in _items) {
      final compressedImage = await _compressImage(item.file);
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

  String? _validateItem(PantryItem item) {
    final name = item.nameController.text.trim();
    final qty = item.qtyController.text.trim();

    if (name.isEmpty) {
      return "Please enter the item name.";
    }

    if (name.length < 3) {
      return "Item name must be at least 3 characters long.";
    }

    if (qty.isEmpty) {
      return "Please enter the quantity.";
    }

    return null;
  }

  Widget _buildPantryItemForm(
    BuildContext context,
    PantryItem item,
    UserState userState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel(
          "Item Image",
          action: _items.first == item
              ? null
              : CircularIconButton(
                  iconAsset: AppAssets.deleteSvg,
                  onTap: () {
                    setState(() => _items.remove(item));
                  },
                ),
        ),
        SizedBox(height: h(10)),
        _buildImagePicker(item),
        SizedBox(height: h(10)),
        _buildFormLabel("Item name"),
        SizedBox(height: h(10)),
        AppTextField(
          textInputAction: TextInputAction.next,
          color: AppColors.apptextFieldStyleTextColor,
          controller: item.nameController,
          hintText: "Enter item name",
          fillColor: const Color(0xFFF9F9F9),
          isFilled: true,
          isLabled: false,
          keyboardType: TextInputType.text,
          label: '',
        ),
        SizedBox(height: h(15)),
        _buildFormLabel("Quantity"),
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
                items: const ["Kg", "Gram", "Litre", "Piece", "Milliliters"],
                onChanged: (val) => setState(() => item.unit = val),
              ),
            ),
            Flexible(
              child: PopupDropdownField(
                label: "Pantry",
                hint: "Select Pantry",
                value: item.pantry,
                items: userState.userStorageAreas
                    .map((area) => area.pantryName)
                    .toList(),
                onChanged: (val) => setState(() => item.pantry = val),
              ),
            ),
          ],
        ),
        SizedBox(height: h(15)),
        _buildFormLabel("Expiring date"),
        SizedBox(height: h(10)),
        _buildDatePicker(item),
      ],
    );
  }

  Widget _buildImagePicker(PantryItem item) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          item.file = await ImagePickerService.showImageSourceDialog(context);
          setState(() {});
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
              CircleAvatar(
                radius: t(24),
                backgroundImage: FileImage(item.file!),
                backgroundColor: Colors.transparent,
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

  Widget _buildDatePicker(PantryItem item) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await DatePickerService.pickDate(context: context);
        if (pickedDate != null) {
          setState(() => item.expireDate.text = pickedDate);
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

  Widget _buildFormLabel(String label, {Widget? action}) {
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

  Widget _buildAddMoreButton() {
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
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: t(15),
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leadingWidth: w(55),
      centerTitle: true,
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: _handleBackNavigation,
          ),
        ],
      ),
      title: Text(
        widget.isMember ? "Request Item" : "Add Item",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
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

  Future<String> _compressImage(File? imageFile) async {
    if (imageFile == null) return "";
    final result = await FlutterImageCompress.compressWithList(
      imageFile.readAsBytesSync(),
      minWidth: 800,
      minHeight: 600,
      quality: 15,
      rotate: 0,
      inSampleSize: 1,
      autoCorrectionAngle: true,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    return "data:image/jpeg;base64,${base64Encode(result)}";
  }
}
