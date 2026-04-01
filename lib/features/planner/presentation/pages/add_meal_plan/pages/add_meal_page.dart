import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/generated_recipe_section.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_action_tile.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_type_selector.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage>
    with AutomaticKeepAliveClientMixin {
  static const List<String> _mealTypes = ["Breakfast", "Lunch", "Dinner"];
  static const Color _backgroundColor = Color(0xffF9F9F9);
  static const double _defaultPadding = 20;
  static const double _appBarLeadingWidth = 55;
  static const double _gapBetweenSections = 20;
  static const double _gapBetweenMealPlanSections = 18;
  static const String _dateFormat = 'dd/MM/yyyy';

  late PlannerBloc _plannerBloc;
  late DateTime _startDate;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _plannerBloc = context.read<PlannerBloc>();
    _initializeDate();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<PlannerBloc, PlannerState>(
      listener: (context, state) => _handleBlocListenerEvents(state),
      builder: (_, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, _) => _handleBackNavigation(context),
          child: Scaffold(
            backgroundColor: _backgroundColor,
            appBar: _buildAppBar(context),
            body: _isLoading ? _buildLoadingView() : _buildMainContent(state),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(PlannerState state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: gapSymmetric(
          horizontal: _defaultPadding,
          vertical: _defaultPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(state),
            gap(height: _gapBetweenSections),
            _buildMealTypeSelector(state),
            _buildGenerateRecipeButton(state),
            _buildMealPlanContent(state),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(_appBarLeadingWidth),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => _handleBackNavigation(context),
          ),
        ],
      ),
      centerTitle: true,
      title: Text(
        "Add New Meal",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildDateSelector(PlannerState state) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, currentState) {
        return SelectDateWidget(
          selectedDate: currentState.selectedDate,
          startDate: _startDate,
          entitlementIsActive: context.read<UserCubit>().state.isPremiumUser,
          onChanged: (selected) => _handleDateSelection(currentState, selected),
        );
      },
    );
  }

  Widget _buildMealTypeSelector(PlannerState state) {
    return MealTypeSelector(
      selectedIndex: state.mealTypeSelectedIndex,
      onSelected: (index) =>
          _plannerBloc.add(UpdateTypeSelectedAndDateEvent(index: index)),
    );
  }

  Widget _buildGenerateRecipeButton(PlannerState state) {
    if (!_shouldShowGenerateButton(state)) {
      return const SizedBox();
    }

    final formattedDate = DateFormat(
      _dateFormat,
    ).format(state.selectedDate ?? DateTime.now());

    return Padding(
      padding: gapOnly(top: _gapBetweenSections),
      child: GenericButtonWidget(
        text: "Generate Recipe",
        onPressed: () => _navigateToGenerateRecipes(formattedDate, state),
      ),
    );
  }

  bool _shouldShowGenerateButton(PlannerState state) {
    if (state.mealPlans.isEmpty) {
      return true;
    }

    final plan = state.mealPlans.first;
    final selectedMealIndex = state.mealTypeSelectedIndex;

    if (selectedMealIndex == 0) return plan.breakfast == null;
    if (selectedMealIndex == 1) return plan.lunch == null;
    if (selectedMealIndex == 2) return plan.dinner == null;

    return false;
  }

  void _navigateToGenerateRecipes(String formattedDate, PlannerState state) {
    context.pushNamed(
      Routes.generateRecipes,
      extra: {
        "selected_date": formattedDate,
        "selected_meal_type": _mealTypes[state.mealTypeSelectedIndex],
        "is_plan": true,
        "is_edit": false,
      },
    );
  }

  Widget _buildMealPlanContent(PlannerState state) {
    if (state.mealPlans.isEmpty) {
      return const SizedBox();
    }

    final plan = state.mealPlans.first;
    final formattedDate = formatDate(state.selectedDate!);
    final isMatchingDate = plan.date == formattedDate;

    if (!isMatchingDate) {
      return const SizedBox();
    }

    return Column(
      children: [
        GeneratedRecipeSection(
          isEdit: false,
          date: formattedDate,
          mealPlan: plan,
          selectedIndex: state.mealTypeSelectedIndex,
        ),
        gap(height: _gapBetweenMealPlanSections),
        MealActionRow(
          selectedIndex: state.mealTypeSelectedIndex,
          plan: plan,
          callback: () => _handleBackNavigation(context),
        ),
      ],
    );
  }

  Future<void> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onConfirm,
  }) {
    return showCustomGenericDialog(
      context: context,
      title: title,
      subtitle: subtitle,
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: () => context.pop(),
    );
  }

  Future<void> _initializeDate() async {
    final rawDate = _plannerBloc.state.startDate;

    _startDate = _parseStartDate(rawDate);
    setState(() => _isLoading = false);
  }

  DateTime _parseStartDate(String? rawDate) {
    if (rawDate?.isNotEmpty == true) {
      try {
        return DateTime.parse(rawDate!);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  void _handleBackNavigation(BuildContext context) {
    final hasPlans = _plannerBloc.state.mealPlans.isNotEmpty;

    if (hasPlans) {
      _showConfirmDialog(
        context,
        title: "Go Back",
        subtitle:
            "If you go back, the meal data you just added will be removed. Continue?",
        onConfirm: () => _navigateToDashboard(),
      );
    } else {
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.goNamed(
        Routes.dashboard,
        extra: {
          'fromNotification': false,
          'entryType': DashboardEntryType.normal,
        },
      );
    });
  }

  void _handleBlocListenerEvents(PlannerState state) {
    if (state.successMessage.isNotEmpty) {
      AppToast.show(state.successMessage, ToastType.success);
      _resetMealPlanState();
      _navigateToDashboard();
    }

    if (state.errorMessage?.isNotEmpty ?? false) {
      AppToast.show(state.errorMessage!, ToastType.error);
    }
  }

  void _resetMealPlanState() {
    _plannerBloc.add(UpdateTypeSelectedAndDateEvent(index: 0));
    _plannerBloc.add(ResetMealPlanState());
  }

  void _handleDateSelection(PlannerState state, DateTime selected) {
    final hasConflictingPlans =
        state.mealPlans.isNotEmpty &&
        state.mealPlans.first.date != formatDate(selected);

    if (hasConflictingPlans) {
      _showConfirmDialog(
        context,
        title: "Change Date",
        subtitle:
            "Changing the date will remove existing meal plans. Continue?",
        onConfirm: () => _confirmDateChange(selected),
      );
    } else {
      _updateDateInBloc(selected);
    }
  }

  void _confirmDateChange(DateTime selected) {
    _updateDateInBloc(selected);
    _resetMealPlanState();
    AppToast.show("Previous plans removed", ToastType.success);
    context.pop();
  }

  void _updateDateInBloc(DateTime date) {
    _plannerBloc.add(UpdateTypeSelectedAndDateEvent(date: date, index: 0));
  }
}
