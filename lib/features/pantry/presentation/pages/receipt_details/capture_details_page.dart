import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/core/common/entities/pantry.dart';
import 'package:foodkitchen/core/common/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/confirm_button.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/image_preview.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/receipt_items.dart';
import 'package:go_router/go_router.dart';

class CaptureDetailsPage extends StatefulWidget {
  final String imagePath;
  const CaptureDetailsPage({super.key, required this.imagePath});

  @override
  State<CaptureDetailsPage> createState() => _CaptureDetailsPageState();
}

class _CaptureDetailsPageState extends State<CaptureDetailsPage> {
  late UserCubit userCubit;
  late PantryBloc pantryBloc;
  ScanReceipt? scanReceipt;

  @override
  void initState() {
    super.initState();
    userCubit = context.read<UserCubit>();
    pantryBloc = context.read<PantryBloc>();
    _loadScanReceipt();
  }

  void _loadScanReceipt() {
    pantryBloc.add(ScanReceiptEvent(filePath: widget.imagePath));
    if (pantryBloc.state is ScanReceiptLoaded) {
      scanReceipt = (pantryBloc.state as ScanReceiptLoaded).scanReceipt;
      setState(() {});
    }
  }

  void _updateItemAmount(int index, int change) {
    final currentAmount = int.parse(scanReceipt!.items[index].amount);
    final newAmount = currentAmount + change;
    if (newAmount >= 0) {
      scanReceipt!.items[index].amount = newAmount.toString();
      setState(() {});
    }
  }

  void _confirmItems() {
    if (scanReceipt == null) return;

    final pantryItems = scanReceipt!.items.map((item) {
      return PantryItemEntity(
        name: item.name,
        quantity: double.parse(item.amount),
        unit: item.unit,
        group: "pantry",
      );
    }).toList();

    final pantryModel = Pantry(
      kitchenId: userCubit.state.activeKitchenId,
      items: pantryItems,
    );

    pantryBloc.add(PantryAddItemEvent(pantry: pantryModel));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PantryBloc, PantryState>(
      listener: (context, state) {
        if (state is ScanReceiptLoaded) {
          AppToast.show(state.scanReceipt.successMessage, ToastType.success);
        } else if (state is PantryFailure) {
          AppToast.show(state.errorMessage, ToastType.error);
        } else if (state is PantrySuccess) {
          context.go(Routes.dashboard);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: SafeArea(
            child: (state is PantryLoading)
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : Padding(
                    padding: gapAll(20),
                    child: Column(
                      children: [
                        ImagePreviewWidget(imagePath: widget.imagePath),
                        SizedBox(height: h(12)),

                        if (scanReceipt != null)
                          Expanded(
                            child: ReceiptItemsListWidget(
                              scanReceipt: scanReceipt!,
                              onIncrement: (index) =>
                                  _updateItemAmount(index, 1),
                              onDecrement: (index) =>
                                  _updateItemAmount(index, -1),
                            ),
                          )
                        else if (state is ScanReceiptLoaded)
                          UpperTile(widget: const Text("No Data Found")),
                      ],
                    ),
                  ),
          ),
          bottomNavigationBar: ConfirmButtonWidget(onPressed: _confirmItems),
        );
      },
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
            onTap: () {
              Navigator.pop(context);
            },
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
            onTap: () {
              context.pop();
            },
          ),
        ),
      ],
    );
  }
}
