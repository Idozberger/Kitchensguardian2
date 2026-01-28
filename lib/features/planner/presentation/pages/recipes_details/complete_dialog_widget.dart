import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:go_router/go_router.dart';

class CompleteDialogWidget {
  static void show(BuildContext context, {required VoidCallback onFinish}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          return GenericDialog(
            borderRadius: h(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Finish Recipe?",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: t(14),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: h(10)),
                Text(
                  "All steps are completed. Are you sure you want to finish this recipe?",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontSize: t(12)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: h(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: w(120),
                      height: h(40),
                      child: GenericButtonWidget(
                        isOutlined: true,
                        isLoading: false,
                        text: "Cancel",
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ),
                    SizedBox(width: w(12)),
                    SizedBox(
                      width: w(120),
                      height: h(40),
                      child: GenericButtonWidget(
                        isLoading: state.isFinishingRecipe,
                        text: "Finish",
                        onPressed: () {
                          onFinish();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
