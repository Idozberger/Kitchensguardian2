import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
import 'package:foodkitchen/core/services/date_picker/date_picker_service.dart'
    show DatePickerService;
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
import 'package:go_router/go_router.dart';

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
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await Future.delayed(Duration.zero);
          _handleBackNavigation();
        }
      },
      child: Scaffold(
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
                      child: BlocBuilder<UserCubit, UserState>(
                        builder: (_, userState) {
                          return ListView.builder(
                            padding: gapZero,
                            shrinkWrap: true,
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Padding(
                                padding: gapOnly(bottom: 10),
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

        bottomNavigationBar: _bottomNavBar(),
      ),
    );
  }

  BlocBuilder<PantryBloc, PantryState> _bottomNavBar() {
    return BlocBuilder<PantryBloc, PantryState>(
      builder: (_, state) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xffF9F9F9)),
            padding: gapOnly(left: 20, right: 20, bottom: 14, top: 14),
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
                      : () async {
                          for (final item in _items) {
                            final name = item.nameController.text.trim();
                            final qty = item.qtyController.text.trim();
                            final unit = item.unit?.trim() ?? '';
                            final pantry = item.pantry?.trim() ?? '';
                            final expireDate = item.expireDate.text.trim();
                            if (item.file == null) {
                              AppToast.show(
                                "Please add an image.",
                                ToastType.error,
                              );
                              return;
                            }

                            if (name.isEmpty) {
                              AppToast.show(
                                "Please enter the item name.",
                                ToastType.error,
                              );
                              return;
                            } else if (name.length < 3) {
                              AppToast.show(
                                "Item name must be at least 3 characters long.",
                                ToastType.error,
                              );
                              return;
                            }
                            if (qty.isEmpty) {
                              AppToast.show(
                                "Please enter the quantity.",
                                ToastType.error,
                              );
                              return;
                            }

                            if (unit.isEmpty) {
                              AppToast.show(
                                "Please select a unit.",
                                ToastType.error,
                              );
                              return;
                            }

                            if (pantry.isEmpty) {
                              AppToast.show(
                                "Please select a pantry.",
                                ToastType.error,
                              );
                              return;
                            }

                            if (expireDate.isEmpty) {
                              AppToast.show(
                                "Please select an expiry date.",
                                ToastType.error,
                              );
                              return;
                            }
                          }

                          final List<PantryItemEntity> pantryItems = [];
                          for (final item in _items) {
                            String bytes = await compressImage(item.file!);
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
                                expireDate: formatExpiry(item.expireDate.text),

                                thumbnail: bytes,
                                expiryStatus: "",
                                stockStatus: "",
                                itemId: "",
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

  Widget _buildPantryItemForm(
    BuildContext context,
    PantryItem item,
    UserState userState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel(
          context,
          "Item Image",
          action: _items.first == item
              ? null
              : CircularIconButton(
                  iconAsset: AppAssets.deleteSvg,
                  onTap: () {
                    _items.remove(item);
                    setState(() {});
                  },
                ),
        ),
        SizedBox(height: h(10)),
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              item.file = await ImagePickerService.showImageSourceDialog(
                context,
              );
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
                    decoration: BoxDecoration(
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
        ),
        SizedBox(height: h(10)),
        _formLabel(context, "Item name"),
        SizedBox(height: h(10)),
        AppTextField(
          textInputAction: TextInputAction.next,
          color: AppColors.apptextFieldStyleTextColor,
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
          textInputAction: TextInputAction.next,
          color: AppColors.apptextFieldStyleTextColor,
          controller: item.qtyController,
          hintText: "Enter item quantity",
          fillColor: const Color(0xffF9F9F9),
          isFilled: true,
          keyboardType: TextInputType.number,
          isLabled: false,

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
                items: userState.userStorageAreas
                    .map((area) => area.pantryName)
                    .toList(),
                onChanged: (val) => setState(() => item.pantry = val),
              ),
            ),
          ],
        ),
        SizedBox(height: h(15)),

        _formLabel(context, "Expiring date"),
        SizedBox(height: h(10)),
        GestureDetector(
          onTap: () async {
            final pickedDate = await DatePickerService.pickDate(
              context: context,
            );
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
            fillColor: const Color(0xffF9F9F9),
            isFilled: true,
            isLabled: false,
            keyboardType: TextInputType.text,
            label: "",
          ),
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
            onTap: () {
              _handleBackNavigation();
            },
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
            // ignore: deprecated_member_use
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

  void goBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);
      if (router.canPop()) {
        router.pop();
      } else {
        debugPrint('⚠️ No route to pop. Ignoring.');
      }
    });
  }

  void _handleBackNavigation() {
    final hasItems = _items.isNotEmpty;

    if (hasItems) {
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
          context,
          title: "Go Back",
          subtitle:
              "If you go back, the items you just added will be removed. Continue?",
          onConfirm: () {
            Navigator.of(context).pop();
            goBack();
          },
        );
      } else {
        goBack();
      }
    } else {
      goBack();
    }
  }

  Future<void> _showConfirmDialog(
    BuildContext context, {
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

  Future<String> compressImage(File imageFile) async {
    var result = await FlutterImageCompress.compressWithList(
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
    String base64Thumbnail = base64Encode(result);

    String dataUri = "data:image/jpeg;base64,$base64Thumbnail";

    return dataUri;
  }
}
