import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/code_resend.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_otp_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isJoinedKitched = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 20, vertical: 20),
      child: ListView(
        children: [
          if (isJoinedKitched) ...[
            _buildPantryTile(context),
            SizedBox(height: h(20)),
            _buildSmartCartTile(context),
            SizedBox(height: h(20)),
            Container(child: Column(children: [

            ],)),
          ],
          if (isJoinedKitched == false) ...[
            _buildHomeUpperTile(context),
            buildNoKitchenFound(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHomeUpperTile(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen you have to:",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: h(15)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: GenericButtonWidget(
                  isOutlined: true,
                  onPressed: () {
                    _showCreateDialog(context);
                  },
                  text: "Create",
                ),
              ),
              SizedBox(width: h(10)),
              Flexible(
                child: GenericButtonWidget(
                  onPressed: () {
                    _showJoinDialog(context);
                  },
                  text: "Join",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPantryTile(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pantry", style: Theme.of(context).textTheme.headlineLarge),
              SvgPicture.asset(AppAssets.pantrySvg),
            ],
          ),
          SizedBox(height: h(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: SvgPicture.asset(AppAssets.scanSvg),
                    label: Text(
                      "Scan",
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
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: SvgPicture.asset(AppAssets.addSvg),
                    label: Text(
                      "Add Item",
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(fontSize: t(14), color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: h(30)),
          Text(
            "No items available in Pantry",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: t(14),
              color: Color(0xff787878),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartCartTile(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Smart Cart",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SvgPicture.asset(AppAssets.pantrySvg),
            ],
          ),
          SizedBox(height: h(15)),
          Text(
            "No items available in Pantry",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: t(14),
              color: Color(0xff787878),
            ),
          ),
          SizedBox(height: h(15)),
          GenericButtonWidget(onPressed: () {}, text: "Generate Grocery List"),
        ],
      ),
    );
  }

  Future<dynamic> _showJoinDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GenericDialog(
          borderRadius: h(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "Reffer Code",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: t(20),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(AppAssets.cancelSvg),
                  ),
                ],
              ),
              SizedBox(height: h(10)),
              OtpField(preFilledStar: true),
              SizedBox(height: h(10)),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: w(147),
                  height: h(40),
                  child: GenericButtonWidget(
                    onPressed: () {
                      setState(() {
                        isJoinedKitched = true;
                      });
                      Navigator.pop(context);
                    },

                    text: "Join",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> _showCreateDialog(BuildContext context) {
    final TextEditingController _kitchenNameController =
        TextEditingController();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GenericDialog(
          borderRadius: h(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "Kitchen Name",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: t(20),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(AppAssets.cancelSvg),
                  ),
                ],
              ),
              SizedBox(height: h(10)),
              AppTextField(
                isLabled: false,
                label: "e.g: Emily Kitchen",
                hintText: "e.g: Emily Kitchen",
                controller: _kitchenNameController,
              ),
              SizedBox(height: h(10)),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: w(147),
                  height: h(40),
                  child: GenericButtonWidget(
                    onPressed: () {
                      if (_kitchenNameController.text.isNotEmpty) {
                        setState(() {
                          isJoinedKitched = true;
                        });
                        Navigator.pop(context);
                      } else {
                        AppToast.show(
                          "Kitchen name cannot be empty",
                          ToastType.error,
                        );
                      }
                    },

                    text: "Create",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
