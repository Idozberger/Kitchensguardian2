// ignore_for_file: unnecessary_brace_in_string_interps
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
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
  late final PlannerBloc _plannerBloc;
  late final UserCubit _userCubit;
  late final PlannerController _controller;

  @override
  void initState() {
    super.initState();
    _plannerBloc = context.read<PlannerBloc>();
    _userCubit = context.read<UserCubit>();
    _controller = PlannerController(
      plannerBloc: _plannerBloc,
      userCubit: _userCubit,
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlannerBloc, PlannerState>(
      listener: _controller.handleStateChanges,
      builder: (context, state) {
        if (state.loadingPlans) {
          return const PlannerLoadingView();
        }

        return Scaffold(
          backgroundColor: const Color(0xffF9F9F9),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: PlannerContent(state: state, controller: _controller),
            ),
          ),
        );
      },
    );
  }
}

class PlannerController {
  final PlannerBloc plannerBloc;
  final UserCubit userCubit;

  PlannerController({required this.plannerBloc, required this.userCubit});

  void initialize() {
    if (userCubit.state.activeKitchenId.isEmpty) return;
    plannerBloc.add(
      GetDateRangeEvent(kitchenId: userCubit.state.activeKitchenId),
    );
  }

  void handleStateChanges(BuildContext context, PlannerState state) {
    if (state.successMessage.isNotEmpty) {
      AppToast.show(state.successMessage, ToastType.success);
    }
    if (state.errorMessage?.isNotEmpty ?? false) {
      AppToast.show(state.errorMessage!, ToastType.error);
    }
  }

  void onDateSelected(DateTime date) {
    plannerBloc.add(
      GetDateBasedPlans(PlannerDateFormatter.toBackendFormat(date)),
    );
  }

  void onAddMealPressed(BuildContext context, PlannerState state) {
    plannerBloc.add(ResetMealPlanState());
    final date = _getEffectiveDate(state);
    plannerBloc.add(UpdateTypeSelectedAndDateEvent(date: date, index: 0));
    context.push(Routes.addMeal);
  }

  void onEditPlan(BuildContext context, MergedRecipePlanEntity plan) {
    plannerBloc.add(ResetMealPlanState());

    _addMealsToBloc(plan);

    plannerBloc.add(
      UpdateTypeSelectedAndDateEvent(
        index: 0,
        date: PlannerDateFormatter.parseBackendDate(plan.date),
      ),
    );
    context.push(Routes.editMeal);
  }

  void onDeletePlan(BuildContext context, MergedRecipePlanEntity plan) {
    PlannerDialogs.showDeleteConfirmation(
      context: context,
      onConfirm: () {
        plannerBloc.add(
          DeletePlanFromRemoteDbEvent(
            mealPlanId: plan.breakfast?.mealplanId ?? "",
            date: plan.date,
            kitchenId: userCubit.state.activeKitchenId,
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  void onAddToCart(BuildContext context) {
    if (AppConstants.entitlementIsActive) {
      AppToast.show("Added to cart", ToastType.success);
    } else {
      AppToast.show("Only premium users can add to cart", ToastType.error);
    }
  }

  DateTime _getEffectiveDate(PlannerState state) {
    if (state.startDate?.isNotEmpty ?? false) {
      return PlannerDateFormatter.parseBackendDate(state.startDate!);
    }
    return DateTime.now();
  }

  void _addMealsToBloc(MergedRecipePlanEntity plan) {
    final meals = [plan.breakfast, plan.lunch, plan.dinner];
    for (final meal in meals) {
      if (meal != null) {
        plannerBloc.add(
          AddMealPlanEvent(
            date: plan.date,
            kitchenId: userCubit.state.activeKitchenId,
            mealPlan: meal as RecipeModel,
          ),
        );
      }
    }
  }

  void dispose() {}
}

class PlannerContent extends StatelessWidget {
  final PlannerState state;
  final PlannerController controller;

  const PlannerContent({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlannerHeader(
            onAddMeal: () => controller.onAddMealPressed(context, state),
          ),
          const SizedBox(height: 15),
          if (state.getAllWeeklyPlans.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 120),
              child: PlannerEmptyState(),
            )
          else
            PlannerList(state: state, controller: controller),
        ],
      ),
    );
  }
}

class PlannerHeader extends StatelessWidget {
  final VoidCallback onAddMeal;

  const PlannerHeader({super.key, required this.onAddMeal});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Plan your meals for the week ahead",
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          GenericButtonWidget(onPressed: onAddMeal, text: "+ Add Meal"),
        ],
      ),
    );
  }
}

class PlannerList extends StatefulWidget {
  final PlannerState state;
  final PlannerController controller;

  const PlannerList({super.key, required this.state, required this.controller});

  @override
  State<PlannerList> createState() => _PlannerListState();
}

class _PlannerListState extends State<PlannerList> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = PlannerDateFormatter.getInitialDate(widget.state);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectDateWidget(
          entitlementIsActive: AppConstants.entitlementIsActive,
          startDate: PlannerDateFormatter.getStartDate(widget.state),
          selectedDate: _selectedDate,
          onChanged: (date) {
            setState(() => _selectedDate = date);
            widget.controller.onDateSelected(date);
          },
        ),
        const SizedBox(height: 15),
        _buildPlanForSelectedDate(),
      ],
    );
  }

  Widget _buildPlanForSelectedDate() {
    final plan = widget.state.dateBasedPlan;

    if (plan.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: PlannerEmptyState(),
      );
    }

    final selectedDateStr = PlannerDateFormatter.toBackendFormat(
      _selectedDate!,
    );
    if (plan[0].date != selectedDateStr) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: PlannerEmptyState(),
      );
    }

    return PlanCard(plan: plan[0], controller: widget.controller);
  }
}

class PlanCard extends StatelessWidget {
  final MergedRecipePlanEntity plan;
  final PlannerController controller;

  const PlanCard({super.key, required this.plan, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DayPlanTile(
        dayLabel: PlannerDateFormatter.toDisplayFormat(plan.date),
        meals: _buildMealsList(),
        viewRecipe: () =>
            context.pushNamed(Routes.viewPlanDetails, extra: plan),
        addToCart: () => controller.onAddToCart(context),
        deletePlan: () => controller.onDeletePlan(context, plan),
        editPlan: () => controller.onEditPlan(context, plan),
      ),
    );
  }

  List<MealTile> _buildMealsList() {
    return [
      if (plan.breakfast != null)
        MealTile(mealType: "Breakfast", mealName: plan.breakfast!.title),
      if (plan.lunch != null)
        MealTile(mealType: "Lunch", mealName: plan.lunch!.title),
      if (plan.dinner != null)
        MealTile(mealType: "Dinner", mealName: plan.dinner!.title),
    ];
  }
}

class PlannerEmptyState extends StatelessWidget {
  const PlannerEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyStateWidget(
        context,
        imagePath: AppAssets.noKitchenFound,
        title: 'No meal found here',
      ),
    );
  }
}

class PlannerLoadingView extends StatelessWidget {
  const PlannerLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: Center(child: Lottie.asset(AppAssets.loader)),
    );
  }
}

class PlannerDateFormatter {
  static String toDisplayFormat(String backendDate) {
    final date = DateTime.parse(backendDate);
    return DateFormat('EEEE dd, yyyy').format(date);
  }

  static String toBackendFormat(DateTime date) {
    return formatDateToMeetBackendDate(date);
  }

  static DateTime parseBackendDate(String backendDate) {
    return formatStringDateToMeetBackendDate(backendDate);
  }

  static DateTime getInitialDate(PlannerState state) {
    if (state.startDate?.isNotEmpty ?? false) {
      try {
        return parseBackendDate(state.startDate!);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime getStartDate(PlannerState state) {
    final dateStr = (state.startDate?.isEmpty ?? true)
        ? toBackendFormat(DateTime.now())
        : state.startDate!;
    return parseBackendDate(dateStr);
  }
}

class PlannerDialogs {
  static Future<void> showDeleteConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    return showCustomGenericDialog(
      context: context,
      title: "Delete Plan",
      subtitle: "Are you sure you want to delete this plan?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }
}
