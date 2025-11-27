import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
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
import 'package:lottie/lottie.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  bool isLoading = true;
  String? localDbPlanStartTime;

  late final PlannerBloc _plannerBloc;
  late final UserCubit _userCubit;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _plannerBloc = context.read<PlannerBloc>();
    _userCubit = context.read<UserCubit>();
    _fetchInitialPlans();
  }

  void _fetchInitialPlans() async {
    if (_userCubit.state.activeKitchenId.isEmpty) return;
    _plannerBloc.add(
      GetDateRangeEvent(kitchenId: _userCubit.state.activeKitchenId),
    );
    await Future.delayed(Duration(seconds: 4));
    _plannerBloc.add(
      GetAllWeeklyPlansEvent(_userCubit.state.activeKitchenId, null),
    );
  }

  String formatDate(String inputDate) {
    final DateTime date = DateTime.parse(inputDate);

    return DateFormat('EEEE dd, yyyy').format(date);
  }

  Widget _buildPlanSection(MergedMealPlanEntity plan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DayPlanTile(
        dayLabel: formatDate(plan.date),
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
        editPlan: () {
          _plannerBloc.add(ResetMealPlanState());
          final meals = [plan.breakfast, plan.lunch, plan.dinner];

          for (final meal in meals) {
            if (meal != null) {
              _plannerBloc.add(
                AddMealPlanEvent(
                  date: plan.date,
                  kitchenId: context.read<UserCubit>().state.activeKitchenId,
                  mealPlan: meal,
                ),
              );
            }
          }

          context.push(Routes.editMeal);
        },
      ),
    );
  }

  Future<dynamic> _showDeleteDialog(
    BuildContext context, {
    required MergedMealPlanEntity plan,
  }) {
    return showCustomGenericDialog(
      context: context,
      title: "Delete Plan",
      subtitle: "Are you sure you want to delete this plan?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: () {
        _plannerBloc.add(
          DeletePlanFromRemoteDbEvent(
            mealPlanId: plan.breakfast?.mealplanId ?? "",
            date: plan.date,
            kitchenId: context.read<UserCubit>().state.activeKitchenId,
          ),
        );

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
    widget: BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        return Column(
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
                DateTime date = _getCurrentDateForBackend(state);
                log("start-date button: ${date}");
                _plannerBloc.add(
                  UpdateTypeSelectedAndDateEvent(date: date, index: 0),
                );

                // ignore: use_build_context_synchronously
                context.push(Routes.addMeal);
              },
              text: "+ Add Meal",
            ),
          ],
        );
      },
    ),
  );
  DateTime _getCurrentDateForBackend(PlannerState state) {
    if (state.startDate != null && state.startDate!.isNotEmpty) {
      log("start-date: ${state.startDate}");
      return formatStringDateToMeetBackendDate(state.startDate!);
    }

    final String selectedDateString = formatDateToMeetBackendDate(
      _selectedDate!,
    );
    return formatStringDateToMeetBackendDate(selectedDateString);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlannerBloc, PlannerState>(
      listener: (context, state) {
        if (state.successMessage.isNotEmpty) {
          AppToast.show(state.successMessage, ToastType.success);
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          AppToast.show(state.errorMessage!, ToastType.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xffF9F9F9),
          body: state.isLoading
              ? Center(child: Lottie.asset(AppAssets.loader))
              : SafeArea(
                  child: Padding(
                    padding: gapOnly(left: 20, right: 20, top: 14, bottom: 14),
                    child: BlocConsumer<PlannerBloc, PlannerState>(
                      listener: (context, state) {},
                      builder: (_, state) {
                        final plan = state.dateBasedPlan ?? [];
                        final todayOnly = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        );
                        String startDate =
                            state.startDate == null || state.startDate!.isEmpty
                            ? formatDateToMeetBackendDate(todayOnly)
                            : state.startDate!;

                        if (startDate.isNotEmpty) {
                          try {
                            _selectedDate ??= formatStringDateToMeetBackendDate(
                              startDate,
                            );
                          } catch (_) {}
                        } else {
                          _selectedDate = todayOnly;
                        }

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
                                BlocBuilder<PlannerBloc, PlannerState>(
                                  builder: (context, state) {
                                    if (state.startDate != null &&
                                        state.startDate!.isNotEmpty &&
                                        _selectedDate == null) {
                                      try {
                                        _selectedDate = DateTime.parse(
                                          state.startDate!,
                                        );
                                      } catch (e) {
                                        _selectedDate = DateTime.now();
                                      }
                                    }

                                    if (state.isLoading &&
                                        state.mealPlans.isEmpty &&
                                        state.startDate == null) {
                                      return Center(
                                        child: Lottie.asset(AppAssets.loader),
                                      );
                                    }

                                    return SelectDateWidget(
                                      entitlementIsActive:
                                          AppConstants.entitlementIsActive,
                                      startDate:
                                          formatStringDateToMeetBackendDate(
                                            state.startDate == null
                                                ? formatDateToMeetBackendDate(
                                                    DateTime.now(),
                                                  )
                                                : state.startDate!.isEmpty
                                                ? formatDateToMeetBackendDate(
                                                    DateTime.now(),
                                                  )
                                                : state.startDate!,
                                          ),
                                      selectedDate: _selectedDate,
                                      onChanged: (date) {
                                        setState(() => _selectedDate = date);

                                        _plannerBloc.add(
                                          GetDateBasedPlans(
                                            formatDateToMeetBackendDate(date),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                gap(height: 15),
                                if (plan.isNotEmpty &&
                                    plan[0].date ==
                                        formatDateToMeetBackendDate(
                                          _selectedDate!,
                                        ))
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
      },
    );
  }
}
