import 'package:flutter/material.dart';
import 'package:foodkitchen/core/navigation/router_navigation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/generated_recipe_section.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_action_tile.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_type_selector.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'add_meal_page_part.dart';

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
            appBar: buildAddMealAppBar(context),
            body: _isLoading
                ? buildAddMealLoadingView()
                : buildAddMealMainContent(state),
          ),
        );
      },
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
        onConfirm: _navigateToDashboard,
      );
    } else {
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    goNamedAfterFrame(
      name: Routes.dashboard,
      extra: {
        'fromNotification': false,
        'entryType': DashboardEntryType.normal,
      },
      isPageMounted: () => mounted,
      pageContext: () => context,
    );
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
    if (!mounted) return;
    context.pop();
  }

  void _updateDateInBloc(DateTime date) {
    _plannerBloc.add(UpdateTypeSelectedAndDateEvent(date: date, index: 0));
  }
}
