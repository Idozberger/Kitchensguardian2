import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  bool isLoading = true;
  late DateTime dateTime;
  List<String> mealString = ["Breakfast", "Lunch", "Dinner"];
  int selectedIndex = 0;

  void updateSelectedIndex(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _fetchStartDateTime();
  }

  void _fetchStartDateTime() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String? startDate = sharedPreferences.getString("start-date");

    if (startDate != null) {
      dateTime = parseDate(startDate);
    } else {
      dateTime = DateTime.now();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        context.read<PlannerBloc>().add(
          GetDateBasedPlans(formatDate(DateTime.now())),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF9F9F9),
        appBar: _buildAppBar(context),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : SafeArea(
                child: SingleChildScrollView(
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
                        // gap(height: 18),
                        // _buildActionButtons(),
                      ],
                    ),
                  ),
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
        "Add New Meal",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildDatePicker() {
    return SelectDateWidget(
      startDate: dateTime,
      onChanged: (date) {
        dateTime = date;

        setState(() {});
      },
      entitlementIsActive: AppConstants.entitlementIsActive,
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
              String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

              context.pushNamed(
                Routes.generateRecipes,
                extra: {
                  "selected_date": formattedDate,
                  "selected_meal_type": mealString[selectedIndex],
                  "is_plan": true,
                },
              );
            },
            text: "Generate Recipe",
          ),
        ],
      ),
    );
  }
}
