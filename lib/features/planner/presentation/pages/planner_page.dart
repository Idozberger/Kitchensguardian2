import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/day_plan_tile.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/meal_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  bool isLoading = true;
  String? localDbPlanStartTime;
  late final PlannerBloc _plannerBloc;
  late DateTime _selectedDate;
  @override
  void initState() {
    super.initState();
    _plannerBloc = context.read<PlannerBloc>();

    _fetchInitialPlans();
  }

  Future<String?> getStartDate() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("start-date");
  }

  void _fetchInitialPlans() async {
    var startDate = await getStartDate();
    localDbPlanStartTime = startDate;
    if (startDate != null) {
      _selectedDate = parseDate(startDate);
    } else {
      _selectedDate = DateTime.now();
    }
    final formattedDate = formatDate(_selectedDate);

    _plannerBloc
      ..add(GetAllWeeklyPlansEvent())
      ..add(GetDateBasedPlans(formattedDate));
    setState(() {
      isLoading = false;
    });
  }

  String _formatReadableDate(String dateString) {
    final date = DateFormat('dd/MM/yyyy').parse(dateString);
    return DateFormat('EEEE dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SafeArea(
              child: Padding(
                padding: gapOnly(left: 20, right: 20, top: 14, bottom: 14),
                child: BlocConsumer<PlannerBloc, PlannerState>(
                  listener: (context, state) {},
                  builder: (_, state) {
                    final plan = state.dateBasedPlan;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          gap(height: 15),
                          if (state.getAllWeeklyPlans.isEmpty)
                            Padding(
                              padding: gapOnly(top: 120),
                              child: _buildEmptyState(),
                            )
                          else ...[
                            SelectDateWidget(
                              entitlementIsActive:
                                  AppConstants.entitlementIsActive,
                              startDate: _selectedDate,
                              onChanged: (date) {
                                setState(() => _selectedDate = date);
                                _plannerBloc.add(
                                  GetDateBasedPlans(formatDate(date)),
                                );
                              },
                            ),
                            gap(height: 15),
                            if (plan.isNotEmpty &&
                                plan[0].date == formatDate(_selectedDate))
                              _buildPlanSection(plan[0])
                            else
                              Padding(
                                padding: gapOnly(top: 64),
                                child: _buildEmptyState(),
                              ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildPlanSection(MergedMealPlanEntity plan) {
    final readableDate = _formatReadableDate(plan.date);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DayPlanTile(
        dayLabel: readableDate,
        meals: [
          if (plan.breakfast != null)
            MealTile(mealType: "Breakfast", mealName: plan.breakfast!.title),
          if (plan.lunch != null)
            MealTile(mealType: "Lunch", mealName: plan.lunch!.title),
          if (plan.dinner != null)
            MealTile(mealType: "Dinner", mealName: plan.dinner!.title),
        ],
        viewRecipe: () {
          context.pushNamed(Routes.viewPlanDetails, extra: plan);
        },
        addToCart: () {
          if (AppConstants.entitlementIsActive) {
            AppToast.show("Added to cart", ToastType.success);
          } else {
            AppToast.show(
              "Only premium users can add to cart",
              ToastType.error,
            );
          }
        },

        deletePlan: () async {
          _showDeleteDialog(context, plan: plan);
        },
        editPlan: () => context.pushNamed(Routes.editMeal, extra: plan),
      ),
    );
  }

  Future<dynamic> _showDeleteDialog(
    BuildContext context, {
    required final plan,
  }) {
    return showCustomGenericDialog(
      context: context,
      title: "Delete Plan",
      subtitle: "Are you sure you want to delete this plan?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: () {
        _plannerBloc.add(DeletePlanEvent(plan.date));

        Navigator.pop(context);
      },
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEmptyState() => Center(
    child: EmptyStateWidget(
      context,
      imagePath: AppAssets.noKitchenFound,
      title: 'No meal found here',
    ),
  );

  Widget _buildHeader(BuildContext context) => UpperTile(
    widget: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Plan your meals for the week ahead",
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        gap(height: 15),
        GenericButtonWidget(
          onPressed: () async {
            _plannerBloc.add(ResetMealPlanState());
            final prefs = await SharedPreferences.getInstance();
            final getStartDate = prefs.getString("start-date");
            final startDate = getStartDate != null
                ? parseDate(getStartDate)
                : DateTime.now();
            _plannerBloc.add(
              UpdateTypeSelectedAndDateEvent(date: startDate, index: 0),
            );
            setState(() {
              if (localDbPlanStartTime != null) {
                _selectedDate = parseDate(localDbPlanStartTime!);
              } else {
                _selectedDate = DateTime.now();
              }
            });
            context.push(Routes.addMeal);
          },
          text: "+ Add Meal",
        ),
      ],
    ),
  );
}
