import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';

Future<dynamic> showCustomGenericDialog({
  required BuildContext context,
  required String title,
  bool isloading = false,
  required String subtitle,
  required String primaryButtonText,
  required String secondaryButtonText,
  required VoidCallback onPrimaryPressed,
  required VoidCallback onSecondaryPressed,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return GenericDialog(
        borderRadius: h(20),
        child: BlocBuilder<PlannerBloc, PlannerState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: t(14),
                  ),
                ),
                SizedBox(height: h(10)),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: t(12),
                    color: const Color(0xff7B7B7B),
                  ),
                ),
                SizedBox(height: h(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: SizedBox(
                        height: h(40),
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onPrimaryPressed,
                          child: state.isFinishingRecipe
                              ? Transform.scale(
                                  scale: 0.7,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                )
                              : Text(
                                  primaryButtonText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(
                                        fontSize: t(12),
                                        color: AppColors.primaryColor,
                                      ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: h(10)),
                    Flexible(
                      child: GenericButtonWidget(
                        onPressed: onSecondaryPressed,
                        text: secondaryButtonText,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
