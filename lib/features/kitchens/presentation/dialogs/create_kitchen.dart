import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';

import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';

Future<dynamic> showCreateKitchenDialog(BuildContext context) {
  final TextEditingController kitchenNameController = TextEditingController();
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return BlocConsumer<KitchenBloc, KitchenState>(
        listener: (context, state) {
          if (state is KitchenSuccess) {
            Navigator.pop(context, true);
          }
        },
        builder: (_, state) {
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
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: w(147),
                    height: h(40),
                    child: GenericButtonWidget(
                      isLoading: state is KitchensLoading,
                      onPressed: () async {
                        if (kitchenNameController.text.isNotEmpty) {
                          context.read<KitchenBloc>().add(
                            CreateKitchenEvent(kitchenNameController.text),
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
