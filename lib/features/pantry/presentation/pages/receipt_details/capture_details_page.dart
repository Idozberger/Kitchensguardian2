import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/date_picker/date_picker_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/confirm_button.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/image_preview.dart';
import 'package:go_router/go_router.dart';

class CaptureDetailsPage extends StatefulWidget {
  final String imagePath;
  const CaptureDetailsPage({super.key, required this.imagePath});

  @override
  State<CaptureDetailsPage> createState() => _CaptureDetailsPageState();
}

class _CaptureDetailsPageState extends State<CaptureDetailsPage> {
  late PantryBloc pantryBloc;
  late UserCubit userCubit;
  List<PantryItem> _items = [];

  @override
  void initState() {
    super.initState();
    pantryBloc = context.read<PantryBloc>();
    userCubit = context.read<UserCubit>();
    pantryBloc.add(ScanReceiptEvent(filePath: widget.imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PantryBloc, PantryState>(
      listener: (context, state) {
        if (state is PantryFailure) {
          AppToast.show(state.errorMessage, ToastType.error);
        } else if (state is PantrySuccess) {
          AppToast.show(
            "Items added to your kitchen successfully!",
            ToastType.success,
          );

          context.go(Routes.dashboard);
        } else if (state is ScanReceiptLoaded) {
          _initializeItems(state.scanReceipt);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: SafeArea(
            child: switch (state) {
              PantryLoading() => Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
              ScanReceiptLoaded() =>
                _items.isEmpty
                    ? const Center(child: Text("No items found"))
                    : SingleChildScrollView(
                        child: Padding(
                          padding: gapAll(20),
                          child: Column(
                            children: [
                              ImagePreviewWidget(imagePath: widget.imagePath),
                              SizedBox(height: h(12)),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(bottom: h(20)),
                                itemCount: _items.length,
                                separatorBuilder: (_, __) => Padding(
                                  padding: gapOnly(bottom: 16),
                                  child: const Divider(
                                    color: Color(0xFFF4F4F4),
                                    height: 1,
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return _buildPantryItemForm(
                                    context,
                                    item,
                                    index,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
              _ => const SizedBox(),
            },
          ),
          bottomNavigationBar: _items.isNotEmpty
              ? ColoredBox(
                  color: Colors.white,
                  child: ConfirmButtonWidget(onPressed: _validateAndSubmit),
                )
              : null,
        );
      },
    );
  }

  void _initializeItems(ScanReceiptEntity scanReceipt) {
    if (_items.isNotEmpty) return;
    setState(() {
      _items = scanReceipt.items
          .map(
            (e) => PantryItem(
              nameController: TextEditingController(text: e.name ?? ''),
              qtyController: TextEditingController(text: e.amount ?? ''),
              expireDate: TextEditingController(),
              manuFacturingDate: TextEditingController(),
              unit: null,
              pantry: null,
            ),
          )
          .toList();
    });
  }

  void _validateAndSubmit() {
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final name = item.nameController.text.trim();
      final qty = item.qtyController.text.trim();
      final unit = item.unit?.trim();
      final pantry = item.pantry?.trim();
      final expiry = item.expireDate.text.trim();

      final displayName = name.isEmpty ? "Item ${i + 1}" : name;

      if (name.isEmpty) {
        AppToast.show(
          "$displayName: please enter the item name.",
          ToastType.error,
        );
        return;
      } else if (name.length < 3) {
        AppToast.show(
          "$displayName: item name must be at least 3 characters long.",
          ToastType.error,
        );
        return;
      } else if (qty.isEmpty) {
        AppToast.show(
          "$displayName: please enter the quantity.",
          ToastType.error,
        );
        return;
      } else if (unit == null || unit.isEmpty) {
        AppToast.show("$displayName: please select a unit.", ToastType.error);
        return;
      } else if (pantry == null || pantry.isEmpty) {
        AppToast.show("$displayName: please select a pantry.", ToastType.error);
        return;
      } else if (expiry.isEmpty) {
        AppToast.show(
          "$displayName: please enter the expiring date.",
          ToastType.error,
        );
        return;
      }
    }

    _confirmItems();
  }

  void _confirmItems() {
    final pantryItems = _items.map((item) {
      return PantryItemEntity(
        name: item.nameController.text.trim(),
        quantity: double.tryParse(item.qtyController.text.trim()) ?? 0.0,
        unit: item.unit ?? "",
        group: item.pantry ?? 'Fridge',
        expireDate: item.expireDate.text.trim(),
      );
    }).toList();

    final pantryModel = Pantry(
      kitchenId: userCubit.state.activeKitchenId,
      items: pantryItems,
    );

    pantryBloc.add(PantryAddItemEvent(pantry: pantryModel));
  }

  Widget _buildPantryItemForm(
    BuildContext context,
    PantryItem item,
    int index,
  ) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _formLabel(
            context,
            "Item name",
            action: CircularIconButton(
              iconAsset: AppAssets.deleteSvg,
              onTap: () {
                setState(() => _items.removeAt(index));
              },
            ),
          ),
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
          _formLabel(context, "Quantity"),
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
          Row(
            spacing: w(12),
            children: [
              Flexible(
                child: PopupDropdownField(
                  label: "Units",
                  hint: "Select Units",
                  value: item.unit,
                  items: const ["Kg", "Gram", "Litre", "Piece"],
                  onChanged: (val) => setState(() => item.unit = val),
                ),
              ),
              Flexible(
                child: PopupDropdownField(
                  label: "Pantry",
                  hint: "Select Pantry",
                  value: item.pantry,
                  items: const [
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
          ),
        ],
      ),
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

  AppBar _buildAppBar() {
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
      title: Text(
        "Meal Scan",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w(16)),
          child: CircularIconButton(
            iconAsset: AppAssets.cameraSwitchSvg,
            onTap: () => context.pop(),
          ),
        ),
      ],
    );
  }
}
