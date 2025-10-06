import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';

class EditMealPage extends StatefulWidget {
  const EditMealPage({super.key});

  @override
  State<EditMealPage> createState() => _EditMealPageState();
}

class _EditMealPageState extends State<EditMealPage> {
  int selectedIndex = 0;

  void updateSelectedIndex(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),
              gap(height: 20),
              _buildMealTypeSection(),
              gap(height: 20),
              _buildCaloriesSection(),
              gap(height: 18),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      centerTitle: true,
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
        "Edit Day Plan",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildDatePicker() {
    return SelectDateWidget(
      startDate: DateTime.now(),
      onChanged: (date) => print("User selected: $date"),
    );
  }

  Widget _buildMealTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Meal Type", style: Theme.of(context).textTheme.headlineLarge),
        gap(height: 20),
        _buildMealTile(
          0,
          "Breakfast",
          AppAssets.breakfastSvg,
          border: selectedIndex == 0 ? const Color(0xffFFDD98) : null,
          bg: selectedIndex == 0 ? const Color(0xffFFFBEB) : null,
        ),
        gap(height: 10),
        _buildMealTile(
          1,
          "Lunch",
          AppAssets.lunchSvg,
          border: selectedIndex == 1 ? const Color(0xffFFDD98) : null,
          bg: selectedIndex == 1 ? const Color(0xffFFFBEB) : null,
        ),
        gap(height: 10),
        _buildMealTile(
          2,
          "Dinner",
          AppAssets.dinnerSvg,

          border: selectedIndex == 2 ? const Color(0xffFFDD98) : null,
          bg: selectedIndex == 2 ? const Color(0xffFFFBEB) : null,
        ),
      ],
    );
  }

  Widget _buildMealTile(
    int index,
    String text,
    String iconPath, {
    Color? border,
    Color? bg,
  }) {
    return UpperTile(
      callback: () => updateSelectedIndex(index),
      height: h(51),
      borderColor: border,
      color: bg,
      widget: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: SvgPicture.asset(iconPath),
          ),
          SizedBox(width: w(15)),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesSection() {
    return Padding(
      padding: gapSymmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GenericButtonWidget(
            onPressed: () {
              context.push(Routes.generateRecipes);
            },
            text: "Generate Recipes",
          ),
          gap(height: 16),
          Row(
            children: [
              const Text("Estimated Calories (Optional)"),
              SizedBox(width: w(5)),
              Image.asset(AppAssets.crownImage, height: h(22)),
            ],
          ),
          gap(height: 16),
          AppTextField(
            hintText: "e.g., 450",
            isLabled: false,
            fillColor: Colors.white,
            isFilled: true,
            controller: TextEditingController(),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: gapSymmetric(horizontal: 12),
      child: Row(
        children: [
          Flexible(
            child: SizedBox(
              width: double.infinity,
              height: h(40),
              child: OutlinedButton(
                onPressed: () {},
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
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
              height: h(40),
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  "Save Edit",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: t(14),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
