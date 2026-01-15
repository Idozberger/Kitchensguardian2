import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/controller/planner_controller.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_content.dart';

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
