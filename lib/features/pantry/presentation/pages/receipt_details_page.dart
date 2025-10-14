import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/domain/entities/pantry.dart';
import 'package:foodkitchen/features/pantry/domain/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';
import 'package:go_router/go_router.dart';

class CaptureDetailsPage extends StatefulWidget {
  final String? imagePath;
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
    userCubit = context.read<UserCubit>();
    pantryBloc = context.read<PantryBloc>();
    getScanReceipt();

    super.initState();
  }

  void getScanReceipt() {
    if (widget.imagePath != null) {
      pantryBloc.add(ScanReceiptEvent(filePath: widget.imagePath!));
      if (pantryBloc.state is ScanReceiptLoaded) {
        scanReceipt = (pantryBloc.state as ScanReceiptLoaded).scanReceipt;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PantryBloc, PantryState>(
      listener: (context, state) {
        if (state is ScanReceiptLoaded) {
          AppToast.show(state.scanReceipt.successMessage, ToastType.success);
        }
        if (state is PantryFailure) {
          AppToast.show(state.errorMessage, ToastType.error);
        }
        if (state is PantrySuccess) {
          context.go(Routes.dashboard);
        }
      },
      builder: (_, state) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: Padding(
              padding: gapAll(20),
              child: Column(
                children: [
                  Container(
                    margin: gapSymmetric(horizontal: 10),
                    height: h(470),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                      image: widget.imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(widget.imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: h(12)),
                  if (state is PantryLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  if (state is ScanReceiptLoaded)
                    Expanded(
                      child: UpperTile(
                        widget: Column(
                          children: [
                            Expanded(
                              child: scanReceipt!.items.isEmpty
                                  ? Text("No items found")
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: scanReceipt!.items.length,
                                      separatorBuilder: (context, index) =>
                                          Padding(
                                            padding: gapSymmetric(vertical: 10),
                                            child: const Divider(
                                              color: Color(0xFFF4F4F4),
                                              height: 1,
                                            ),
                                          ),
                                      itemBuilder: (context, index) {
                                        var item = scanReceipt!.items[index];
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: ListItemWidget(
                                                text: item.name,
                                                crossAlignment:
                                                    CrossAxisAlignment.center,
                                              ),
                                            ),

                                            Row(
                                              children: [
                                                _iconButtonContainer(
                                                  iconPath:
                                                      AppAssets.decreamentSvg,
                                                  onTap: () {
                                                    int amount =
                                                        int.parse(item.amount) -
                                                        1;
                                                    scanReceipt!
                                                        .items[index]
                                                        .amount = amount
                                                        .toString();
                                                    setState(() {});
                                                  },
                                                ),
                                                SizedBox(width: w(8)),
                                                Text(
                                                  item.amount,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium
                                                      ?.copyWith(
                                                        fontSize: t(10),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                                SizedBox(width: w(8)),
                                                _iconButtonContainer(
                                                  iconPath:
                                                      AppAssets.increamentSvg,
                                                  onTap: () {
                                                    int amount =
                                                        int.parse(item.amount) +
                                                        1;
                                                    scanReceipt!
                                                        .items[index]
                                                        .amount = amount
                                                        .toString();
                                                    setState(() {});
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: gapAll(20),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GenericButtonWidget(
                    onPressed: () {
                      final List<PantryItemEntity> pantryItems = scanReceipt!
                          .items
                          .map((item) {
                            return PantryItemEntity(
                              name: item.name,
                              quantity: double.parse(item.amount),
                              unit: item.unit,
                              group: "pantry",
                            );
                          })
                          .toList();

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
                    },
                    text: "Confirm",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _iconButtonContainer({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4D2D2)),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(iconPath),
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
        SizedBox(width: w(16)),
        CircularIconButton(
          iconAsset: AppAssets.cameraSwitchSvg,
          onTap: () {
            getScanReceipt();
          },
        ),
        SizedBox(width: w(16)),
      ],
    );
  }
}
