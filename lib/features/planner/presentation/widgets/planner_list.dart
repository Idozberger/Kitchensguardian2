import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';

import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/controller/planner_controller.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/plan_card.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_content.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_date_formatter.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_empty_state.dart';

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

    _initializeSelectedDate();
  }

  @override
  void didUpdateWidget(PlannerList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.dateBasedPlan.isNotEmpty) {
      _initializeSelectedDate();
    }
  }

  void _initializeSelectedDate() async {
    DateTime initialDate;

    if (widget.state.dateBasedPlan.isNotEmpty) {
      initialDate = PlannerDateFormatter.parseBackendDate(
        widget.state.dateBasedPlan[0].date,
      );
    } else {
      initialDate = PlannerDateFormatter.getInitialDate(widget.state);
    }

    setState(() => _selectedDate = initialDate);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlannerBloc, PlannerState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          children: [
            SelectDateWidget(
              entitlementIsActive: true,
              startDate: PlannerDateFormatter.getStartDate(widget.state),
              selectedDate: _selectedDate,
              onChanged: (date) {
                setState(() => _selectedDate = date);
                widget.controller.onDateSelected(date);
              },
            ),
            const SizedBox(height: 15),

            _buildPlanForSelectedDate(state),
          ],
        );
      },
    );
  }

  Widget _buildPlanForSelectedDate(PlannerState state) {
    final plan = state.getAllWeeklyPlans;

    if (plan.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: PlannerEmptyState(),
      );
    }

    if (_selectedDate == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: PlannerEmptyState(),
      );
    }

    final selectedDateStr = PlannerDateFormatter.toBackendFormat(
      _selectedDate!,
    );

    final matchingPlan = plan.firstWhereOrNull(
      (p) => p.date == selectedDateStr,
    );

    if (matchingPlan == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: PlannerEmptyState(),
      );
    }

    return PlanCard(plan: matchingPlan, controller: widget.controller);
  }
}
