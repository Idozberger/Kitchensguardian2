import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';

Future<dynamic> showCreateKitchenDialog(BuildContext context) {
  final TextEditingController kitchenNameController = TextEditingController();
  // Measurement system chosen at creation (BRD UC-03); defaults to metric.
  final ValueNotifier<String> unitSystem = ValueNotifier<String>(
    unitSystemToApi(UnitSystem.metric),
  );
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            Navigator.pop(context, true);
          }
        },
        builder: (_, homeState) {
          return GenericDialog(
            borderRadius: h(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kitchen Name",
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: t(20),
                          ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      icon: SvgPicture.asset(AppAssets.cancelSvg),
                    ),
                  ],
                ),
                SizedBox(height: h(10)),
                AppTextField(
                  isLabled: false,
                  label: "e.g: Emily Kitchen",
                  hintText: "e.g: Emily Kitchen",
                  controller: kitchenNameController,
                ),
                SizedBox(height: h(10)),
                ValueListenableBuilder<String>(
                  valueListenable: unitSystem,
                  builder: (_, selected, _) => PopupDropdownField(
                    label: "Measurement System",
                    hint: "Select system",
                    value: selected,
                    items: unitSystemOptions,
                    displayLabel: unitSystemDisplayLabel,
                    onChanged: (value) {
                      if (value != null) unitSystem.value = value;
                    },
                  ),
                ),
                SizedBox(height: h(10)),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: w(147),
                    height: h(40),
                    child: GenericButtonWidget(
                      isLoading: homeState.isLoading,
                      onPressed: () async {
                        if (kitchenNameController.text.isNotEmpty) {
                          context.read<HomeBloc>().add(
                            CreateKitchenEventForHome(
                              kitchenNameController.text,
                              unitSystem: unitSystemFromApi(unitSystem.value),
                            ),
                          );
                        } else {
                          AppToast.show(
                            "Kitchen name cannot be empty",
                            ToastType.error,
                          );
                        }
                      },

                      text: "Create",
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
