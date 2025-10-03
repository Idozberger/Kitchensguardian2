import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/code_resend.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';

class MyPantryPage extends StatefulWidget {
  const MyPantryPage({super.key});

  @override
  State<MyPantryPage> createState() => _MyPantryPageState();
}

class _MyPantryPageState extends State<MyPantryPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xffF9F9F9),
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Column(
            children: [
              /// Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primaryColor,
                        width: h(2),
                      ),
                    ),
                  ),
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: const Color(0xff787878),
                  tabs: const [
                    Tab(text: "All Items"),
                    Tab(text: "Expiring"),
                    Tab(text: "Low Stock"),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildItemList(context, "Milk", true),
                    _buildItemList(context, "Milk"),
                    _buildItemList(context, "Milk"),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: gapSymmetric(horizontal: 20, vertical: 10),
                child: UpperTile(
                  widget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Request List",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(height: h(10)),
                      Text(
                        "Request host to buy groceries or dinner",
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              fontSize: t(15),
                              color: Color(0xff787878),
                            ),
                      ),
                      SizedBox(height: h(20)),
                      GenericButtonWidget(
                        onPressed: () {},
                        text: "Request Now",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(
    BuildContext context,
    String type, [
    bool requestButton = false,
  ]) {
    return Expanded(
      child: ListView.separated(
        itemCount: 8,
        shrinkWrap: true,
        separatorBuilder: (context, index) =>
            const Divider(color: Color(0xffF4F4F4)),
        padding: gapSymmetric(horizontal: 20, vertical: 15),
        itemBuilder: (context, index) {
          return PantryItemCard(
            title: "$type ${index + 1}",
            quantity: "1 Bottle",
            unit: "1 Litre",
            pantry: "Fridge",
            expiry: "Expires in ${index + 1} days",
          );
        },
      ),
    );
  }

  /// Custom AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(h(70)),
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: h(40),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(Routes.scanMeal);
                    },
                    icon: SvgPicture.asset(AppAssets.scanSvg),
                    label: Text(
                      "Scan",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontSize: t(14),
                            color: AppColors.primaryColor,
                          ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: w(10)),
              Expanded(
                child: SizedBox(
                  height: h(40),
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(Routes.addItem),
                    icon: SvgPicture.asset(AppAssets.addSvg),
                    label: Text(
                      "Add Item",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: t(14), color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: Text(
        "My Pantry",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}

class PantryItemCard extends StatefulWidget {
  final String title;
  final String quantity;
  final String unit;
  final String pantry;
  final String expiry;

  const PantryItemCard({
    super.key,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.pantry,
    required this.expiry,
  });

  @override
  State<PantryItemCard> createState() => _PantryItemCardState();
}

class _PantryItemCardState extends State<PantryItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: gapSymmetric(vertical: 5),
      padding: gapAll(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(h(10)),
        border: Border.all(color: const Color(0xffD4D2D2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  if (!_isExpanded) ...[
                    SizedBox(width: w(12)),
                    _buildInlineInfo(widget.quantity),
                    _dot(),
                    _buildInlineInfo(widget.unit),
                    _dot(),
                    _buildInlineInfo(widget.pantry),
                  ],
                ],
              ),
              IconButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(AppAssets.downArrow),
                ),
              ),
            ],
          ),

          /// Expanded Details
          if (_isExpanded) ...[
            SizedBox(height: h(15)),
            Row(
              children: [
                _buildInlineInfo(widget.quantity),
                _dot(),
                _buildInlineInfo(widget.unit),
                _dot(),
                _buildInlineInfo(widget.pantry),
              ],
            ),
            SizedBox(height: h(10)),
            Text(
              widget.expiry,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: t(14),
                color: const Color(0xff787878),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: h(15)),

            /// Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _circleButton(AppAssets.editSvg, () {}),
                _circleButton(AppAssets.cartSvg, () {}),
                _circleButton(AppAssets.listCheckedSvg, () {}),
                _circleButton(AppAssets.deleteSvg, () {
                  _showDeleteDialog(context);
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineInfo(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: t(14),
        color: const Color(0xff787878),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _dot() => Padding(
    padding: EdgeInsets.symmetric(horizontal: w(8)),
    child: Container(
      width: w(4),
      height: h(4),
      decoration: const BoxDecoration(
        color: Color(0xff787878),
        shape: BoxShape.circle,
      ),
    ),
  );

  Widget _circleButton(String asset, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(left: w(8)),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor),
        shape: BoxShape.circle,
      ),
      child: CircularIconButton(iconAsset: asset, onTap: onTap),
    );
  }

  Future<dynamic> _showDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GenericDialog(
          borderRadius: h(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Remove Item",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(20),
                ),
              ),
              SizedBox(height: h(10)),
              Text(
                "Are you sure you want to delete this item?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(15),
                  color: Color(0xff7B7B7B),
                ),
              ),
              SizedBox(height: h(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          AppToast.show("Item removed", ToastType.success);
                          Navigator.pop(context);
                        },

                        child: Text(
                          "Yes",
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                fontSize: t(14),
                                color: AppColors.primaryColor,
                              ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: h(10)),
                  Flexible(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        child: Text(
                          "Cancel",
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(fontSize: t(14), color: Colors.black),
                        ),
                      ),
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
}
