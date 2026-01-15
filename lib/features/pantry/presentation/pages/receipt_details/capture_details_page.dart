import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/date_picker/date_picker_service.dart';
import 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';
import 'package:foodkitchen/core/services/image_picker/image_picker_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
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
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/animated_dots.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/confirm_button.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/image_preview.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class CaptureDetailsPage extends StatefulWidget {
  final String imagePath;
  const CaptureDetailsPage({super.key, required this.imagePath});

  @override
  State<CaptureDetailsPage> createState() => _CaptureDetailsPageState();
}

class _CaptureDetailsPageState extends State<CaptureDetailsPage> {
  late PantryBloc _pantryBloc;
  late UserCubit _userCubit;
  List<PantryItem> _items = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pantryBloc = context.read<PantryBloc>();
    _userCubit = context.read<UserCubit>();
    _pantryBloc.add(ScanReceiptEvent(filePath: widget.imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PantryBloc, PantryState>(
      listener: _handleStateChange,
      builder: (context, state) => Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(state),
        bottomNavigationBar: _items.isNotEmpty && state is! PantryLoading
            ? ColoredBox(
                color: Colors.white,
                child: ConfirmButtonWidget(
                  onPressed: _validateAndSubmit,
                  isloading: state is PantryLoading,
                ),
              )
            : null,
      ),
    );
  }

  void _handleStateChange(BuildContext context, PantryState state) {
    if (state is PantryFailure) {
      setState(() => _errorMessage = state.errorMessage);
    } else if (state is PantrySuccess) {
      AppToast.show(
        "Items added to your kitchen successfully!",
        ToastType.success,
      );
      context.go(Routes.dashboard);
    } else if (state is ScanReceiptLoaded) {
      _initializeItems(state.scanReceipt);
    }
  }

  Widget _buildBody(PantryState state) {
    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    return SafeArea(
      child: switch (state) {
        PantryLoading() => _buildLoadingState(),
        PantryScanItemsLoading() => _buildScanningState(),
        ScanReceiptLoaded() =>
          _items.isEmpty ? _buildEmptyState() : _buildItemsListView(),
        _ => const SizedBox(),
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Lottie.asset(
        AppAssets.loader,
        height: h(400),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildScanningState() {
    return Center(
      child: Padding(
        padding: gapAll(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: w(140),
                  height: h(140),
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor.withOpacity(0.3),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.7, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  builder: (_, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: w(100),
                        height: h(100),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor.withOpacity(0.6),
                              AppColors.primaryColor.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Lottie.asset(
                  AppAssets.loader,
                  width: w(120),
                  height: h(120),
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(height: h(40)),
            Text(
              "Scanning your receipt...",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: t(22),
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: h(16)),
            AnimatedDotsText(
              text: "Analyzing items with AI",
              style: TextStyle(
                fontSize: t(15),
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            SizedBox(height: h(20)),
            Text(
              "This usually takes a few seconds",
              style: TextStyle(fontSize: t(13), color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsListView() {
    return SingleChildScrollView(
      child: Padding(
        padding: gapAll(20),
        child: Column(
          children: [
            ImagePreviewWidget(imagePath: widget.imagePath),
            SizedBox(height: h(12)),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: h(20)),
              itemCount: _items.length,
              separatorBuilder: (_, __) => Padding(
                padding: gapOnly(bottom: 16),
                child: const Divider(color: Color(0xFFF4F4F4), height: 1),
              ),
              itemBuilder: (context, index) =>
                  _buildPantryItemForm(context, _items[index], index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: gapSymmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.groceryEmpty,
              width: w(220),
              height: h(220),
              fit: BoxFit.contain,
            ),
            SizedBox(height: h(32)),
            Text(
              "No items detected",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: t(24),
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: h(16)),
            Text(
              "We couldn't recognize any items from this receipt.\nTry taking a clearer photo or add items manually.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: t(15),
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            SizedBox(height: h(48)),
            GenericButtonWidget(
              onPressed: () => DocumentScannerService().scanDocument(
                context,
                replacement: true,
              ),
              text: "Retake",
            ),
            SizedBox(height: h(16)),
            TextButton(
              onPressed: () => context.push(Routes.addItem),
              child: Text(
                "Add Items Manually",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: t(15),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: gapSymmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Oops!",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: t(24),
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(height: h(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: t(15), color: Colors.grey.shade700),
            ),
            SizedBox(height: h(32)),
            GenericButtonWidget(
              text: "Retry",
              onPressed: () {
                setState(() => _errorMessage = null);
                _pantryBloc.add(ScanReceiptEvent(filePath: widget.imagePath));
              },
            ),
            SizedBox(height: h(16)),
            TextButton(
              onPressed: () => DocumentScannerService().scanDocument(
                context,
                replacement: true,
              ),
              child: Text(
                "Retake",
                style: TextStyle(
                  fontSize: t(15),
                  color: AppColors.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeItems(ScanReceiptEntity scanReceipt) {
    if (_items.isNotEmpty) return;
    setState(() {
      _items = scanReceipt.items
          .map(
            (e) => PantryItem(
              pantry: e.group,
              nameController: TextEditingController(text: e.name),
              qtyController: TextEditingController(text: e.amount),
              expireDate: TextEditingController(
                text: e.expireDate == "null"
                    ? formatDate(DateTime.now())
                    : e.expireDate,
              ),
              manuFacturingDate: TextEditingController(),
              unit: e.unit,
              fileBytes: e.thumbnail,
            ),
          )
          .toList();
    });
  }

  void _validateAndSubmit() {
    for (int i = 0; i < _items.length; i++) {
      final validation = _validateItem(_items[i], i);
      if (validation != null) {
        AppToast.show(validation, ToastType.error);
        return;
      }
    }
    _confirmItems();
  }

  String? _validateItem(PantryItem item, int index) {
    final name = item.nameController.text.trim();
    final qty = item.qtyController.text.trim();
    final unit = item.unit?.trim();
    final pantry = item.pantry?.trim();
    final expiry = item.expireDate.text.trim();
    final displayName = name.isEmpty ? "Item ${index + 1}" : name;

    if (name.isEmpty) return "$displayName: please enter the item name.";
    if (name.length < 3) {
      return "$displayName: item name must be at least 3 characters long.";
    }
    if (qty.isEmpty) return "$displayName: please enter the quantity.";
    if (unit == null || unit.isEmpty) {
      return "$displayName: please select a unit.";
    }
    if (pantry == null || pantry.isEmpty) {
      return "$displayName: please select a pantry.";
    }
    if (expiry.isEmpty) {
      return "$displayName: please enter the expiring date.";
    }
    return null;
  }

  Future<String> _compressImage(File imageFile) async {
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

  Future<String?> _getImageBase64(PantryItem item) async {
    try {
      if (item.file != null) {
        return await _compressImage(item.file!);
      } else if (item.fileBytes != null && item.fileBytes!.isNotEmpty) {
        return "data:image/jpeg;base64,${base64Encode(item.fileBytes!)}";
      }
    } catch (e) {
      debugPrint("Image compression failed: $e");
    }
    return null;
  }

  Future<void> _confirmItems() async {
    final pantryItems = <PantryItemEntity>[];

    for (final item in _items) {
      final thumbnailBase64 = await _getImageBase64(item);

      pantryItems.add(
        PantryItemEntity(
          name: item.nameController.text.trim(),
          quantity: double.tryParse(item.qtyController.text.trim()) ?? 0.0,
          unit: item.unit ?? "",
          group: item.pantry ?? 'Fridge',
          expireDate: item.expireDate.text.trim(),
          thumbnail: thumbnailBase64 ?? "",
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

    _pantryBloc.add(PantryAddScannedItemEvent(pantry: pantryModel));
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
          _buildFormLabel(
            context,
            "Item Image",
            action: _items.first != item
                ? CircularIconButton(
                    iconAsset: AppAssets.deleteSvg,
                    onTap: () {
                      _items.remove(item);
                      setState(() {});
                    },
                  )
                : null,
          ),
          SizedBox(height: h(10)),
          _buildImagePicker(item),
          SizedBox(height: h(10)),
          _buildFormLabel(context, "Item name"),
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
          _buildFormLabel(context, "Quantity"),
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
          _buildDropdownsRow(item),
          SizedBox(height: h(15)),
          _buildFormLabel(context, "Expiring date"),
          SizedBox(height: h(10)),
          _buildDatePicker(item),
        ],
      ),
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
              )
            else if (item.fileBytes != null && item.fileBytes!.isNotEmpty)
              CircleAvatar(
                radius: t(24),
                backgroundImage: MemoryImage(item.fileBytes!),
                backgroundColor: Colors.transparent,
              )
            else
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
                child: Icon(Icons.image, color: Colors.white),
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

  Widget _buildDropdownsRow(PantryItem item) {
    return Row(
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
            items: _userCubit.state.userStorageAreas
                .map((storage) => storage.pantryName)
                .toList(),
            onChanged: (val) => setState(() => item.pantry = val),
          ),
        ),
      ],
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
    );
  }

  Widget _buildFormLabel(BuildContext context, String label, {Widget? action}) {
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
            onTap: () => context.pop(),
          ),
        ],
      ),
      title: Text(
        "Receipt Scan",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w(16)),
          child: CircularIconButton(
            iconAsset: AppAssets.cameraSwitchSvg,
            onTap: () => DocumentScannerService().scanDocument(
              context,
              replacement: true,
            ),
          ),
        ),
      ],
    );
  }
}
